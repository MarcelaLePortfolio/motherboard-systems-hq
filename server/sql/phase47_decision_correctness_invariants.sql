/*
Phase 47 — Decision correctness invariants for claim/lease/reclaim.
SQL-first: fail-fast via RAISE EXCEPTION, but schema-flex:
- We REQUIRE: public.tasks(task_id) and public.task_events(id, task_id, ts, kind)
- We OPTIONAL: status/terminal/lease/heartbeat columns (only enforce invariants we can ground)

Goal: never "green" based on missing core tables/columns; but avoid failing solely due to
different column names in older/newer schemas.
*/

DO $$
DECLARE
  -- required core columns
  col_task_id text := NULL;

  col_ev_id   text := NULL;
  col_ev_tid  text := NULL;
  col_ev_ts   text := NULL;
  col_ev_kind text := NULL;

  -- optional tasks columns (mapped if present)
  col_status        text := NULL;  -- task_status | status
  col_is_terminal   text := NULL;  -- is_terminal | terminal
  col_lease_owner   text := NULL;  -- lease_owner | lease_actor | lease_holder
  col_lease_exp     text := NULL;  -- lease_expires_at | lease_until | lease_expires_ts
  col_hb_ts         text := NULL;  -- last_heartbeat_ts | heartbeat_ts | last_heartbeat_ms

  _msg text;

  -- helper
  FUNCTION pick_col(_tbl text, _candidates text[]) RETURNS text
  LANGUAGE plpgsql AS $f$
  DECLARE c text;
  BEGIN
    FOREACH c IN ARRAY _candidates LOOP
      IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema='public'
          AND table_name=_tbl
          AND column_name=c
      ) THEN
        RETURN c;
      END IF;
    END LOOP;
    RETURN NULL;
  END;
  $f$;
BEGIN
  -- --- required tables ---
  IF to_regclass('public.tasks') IS NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: missing table public.tasks';
  END IF;
  IF to_regclass('public.task_events') IS NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: missing table public.task_events';
  END IF;

  -- --- required columns ---
  col_task_id := pick_col('tasks', ARRAY['task_id']);
  IF col_task_id IS NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: missing required column tasks.task_id';
  END IF;

  col_ev_id   := pick_col('task_events', ARRAY['id']);
  col_ev_tid  := pick_col('task_events', ARRAY['task_id']);
  col_ev_ts   := pick_col('task_events', ARRAY['ts','created_at']);
  col_ev_kind := pick_col('task_events', ARRAY['kind','event_kind']);

  IF col_ev_id IS NULL OR col_ev_tid IS NULL OR col_ev_ts IS NULL OR col_ev_kind IS NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: task_events missing required columns (need id, task_id, ts, kind/event_kind)';
  END IF;

  -- --- optional mappings ---
  col_status      := pick_col('tasks', ARRAY['task_status','status']);
  col_is_terminal := pick_col('tasks', ARRAY['is_terminal','terminal']);
  col_lease_owner := pick_col('tasks', ARRAY['lease_owner','lease_actor','lease_holder']);
  col_lease_exp   := pick_col('tasks', ARRAY['lease_expires_at','lease_until','lease_expires_ts']);
  col_hb_ts       := pick_col('tasks', ARRAY['last_heartbeat_ts','heartbeat_ts','last_heartbeat_ms']);

  -- ---------------------------------------------------------------------------
  -- Invariant A: task_events ordering is strictly increasing per task by (ts, id)
  -- ---------------------------------------------------------------------------
  EXECUTE format($q$
    SELECT 1
    FROM (
      SELECT
        %1$I AS task_id,
        %2$I AS ts,
        %3$I AS id,
        lag(%2$I) OVER (PARTITION BY %1$I ORDER BY %2$I ASC, %3$I ASC) AS prev_ts,
        lag(%3$I) OVER (PARTITION BY %1$I ORDER BY %2$I ASC, %3$I ASC) AS prev_id
      FROM public.task_events
    ) w
    WHERE prev_ts IS NOT NULL
      AND (ts < prev_ts OR (ts = prev_ts AND id <= prev_id))
    LIMIT 1
  $q$, col_ev_tid, col_ev_ts, col_ev_id)
  INTO _msg;

  IF _msg IS NOT NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: task_events are not strictly increasing per task by (ts,id)';
  END IF;

  -- ---------------------------------------------------------------------------
  -- Invariant B: terminal consistency (only if we can read tasks terminal flag)
  -- ---------------------------------------------------------------------------
  IF col_is_terminal IS NULL THEN
    RAISE NOTICE 'Phase47: skipping terminal consistency (no tasks.is_terminal/terminal column)';
  ELSE
    -- tasks.is_terminal=true => terminal-ish event exists
    EXECUTE format($q$
      SELECT 1
      FROM public.tasks t
      WHERE t.%1$I = TRUE
        AND NOT EXISTS (
          SELECT 1
          FROM public.task_events e
          WHERE e.%2$I = t.%3$I
            AND (
              e.%4$I ILIKE 'task.terminated%%' OR
              e.%4$I IN ('task.completed','task.failed','task.canceled','task.cancelled')
            )
        )
      LIMIT 1
    $q$, col_is_terminal, col_ev_tid, col_task_id, col_ev_kind)
    INTO _msg;

    IF _msg IS NOT NULL THEN
      RAISE EXCEPTION 'Phase47 invariant failure: tasks.terminal=true without a terminal-ish task_event';
    END IF;

    -- terminal-ish event exists => tasks.is_terminal=true
    EXECUTE format($q$
      SELECT 1
      FROM public.task_events e
      JOIN public.tasks t ON t.%1$I = e.%2$I
      WHERE (
        e.%3$I ILIKE 'task.terminated%%' OR
        e.%3$I IN ('task.completed','task.failed','task.canceled','task.cancelled')
      )
        AND t.%4$I = FALSE
      LIMIT 1
    $q$, col_task_id, col_ev_tid, col_ev_kind, col_is_terminal)
    INTO _msg;

    IF _msg IS NOT NULL THEN
      RAISE EXCEPTION 'Phase47 invariant failure: terminal-ish task_event exists but tasks.terminal=false';
    END IF;
  END IF;

  -- ---------------------------------------------------------------------------
  -- Invariant C: lease validity for running tasks (only if we can read status + lease fields)
  -- ---------------------------------------------------------------------------
  IF col_status IS NULL OR col_lease_owner IS NULL OR col_lease_exp IS NULL THEN
    RAISE NOTICE 'Phase47: skipping lease validity for running tasks (need status + lease_owner + lease_expires_at mapping)';
  ELSE
    EXECUTE format($q$
      SELECT 1
      FROM public.tasks t
      WHERE t.%1$I = 'running'
        AND (
          t.%2$I IS NULL OR
          t.%3$I IS NULL OR
          t.%3$I <= now()
        )
      LIMIT 1
    $q$, col_status, col_lease_owner, col_lease_exp)
    INTO _msg;

    IF _msg IS NOT NULL THEN
      RAISE EXCEPTION 'Phase47 invariant failure: running task missing/expired lease (owner/expires)';
    END IF;

    IF col_is_terminal IS NOT NULL THEN
      EXECUTE format($q$
        SELECT 1
        FROM public.tasks t
        WHERE t.%1$I = TRUE
          AND (t.%2$I IS NOT NULL OR t.%3$I IS NOT NULL)
        LIMIT 1
      $q$, col_is_terminal, col_lease_owner, col_lease_exp)
      INTO _msg;

      IF _msg IS NOT NULL THEN
        RAISE EXCEPTION 'Phase47 invariant failure: terminal task retains lease fields';
      END IF;
    END IF;
  END IF;

  -- ---------------------------------------------------------------------------
  -- Invariant D: reclaim contradiction detection (event-only; always enforced)
  -- - multiple acquisitions without intervening release marker in the "last segment"
  -- ---------------------------------------------------------------------------
  EXECUTE format($q$
    SELECT 1
    FROM (
      WITH marks AS (
        SELECT
          e.%1$I AS task_id,
          e.%2$I AS ts,
          e.%3$I AS id,
          CASE
            WHEN (e.%4$I ILIKE 'lease.%%releas%%'
               OR e.%4$I ILIKE 'lease.%%expired%%'
               OR e.%4$I ILIKE 'task.terminated%%'
               OR e.%4$I IN ('task.completed','task.failed','task.canceled','task.cancelled'))
            THEN 1 ELSE 0
          END AS is_release,
          CASE
            WHEN (e.%4$I ILIKE 'lease.%%acquir%%'
               OR e.%4$I ILIKE 'task.claim%%'
               OR e.%4$I ILIKE 'claim.%%')
            THEN 1 ELSE 0
          END AS is_acquire
        FROM public.task_events e
      ),
      seg AS (
        SELECT
          task_id,
          ts,
          id,
          is_acquire,
          sum(is_release) OVER (PARTITION BY task_id ORDER BY ts ASC, id ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS seg_id
        FROM marks
      ),
      last_seg AS (
        SELECT DISTINCT ON (task_id) task_id, seg_id
        FROM seg
        ORDER BY task_id, seg_id DESC
      ),
      acquires_in_last AS (
        SELECT s.task_id, count(*) AS acquire_ct
        FROM seg s
        JOIN last_seg l ON l.task_id = s.task_id AND l.seg_id = s.seg_id
        WHERE s.is_acquire = 1
        GROUP BY s.task_id
      )
      SELECT 1
      FROM acquires_in_last
      WHERE acquire_ct > 1
      LIMIT 1
    ) q
  $q$, col_ev_tid, col_ev_ts, col_ev_id, col_ev_kind)
  INTO _msg;

  IF _msg IS NOT NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: multiple lease/claim acquisitions without release in last segment (reclaim contradiction)';
  END IF;

  -- ---------------------------------------------------------------------------
  -- Invariant E: heartbeat sanity (only if we can read status + heartbeat + lease_exp)
  -- ---------------------------------------------------------------------------
  IF col_status IS NULL OR col_hb_ts IS NULL OR col_lease_exp IS NULL THEN
    RAISE NOTICE 'Phase47: skipping heartbeat sanity (need status + heartbeat_ts + lease_expires_at mapping)';
  ELSE
    -- heartbeat is assumed to be epoch-ms (as in earlier phases); we keep a wide window to avoid false positives
    EXECUTE format($q$
      SELECT 1
      FROM public.tasks t
      WHERE t.%1$I = 'running'
        AND (
          t.%2$I IS NULL OR
          t.%2$I > (extract(epoch from now()) * 1000)::bigint + 60000 OR
          t.%2$I < (extract(epoch from (t.%3$I - interval '10 minutes')) * 1000)::bigint
        )
      LIMIT 1
    $q$, col_status, col_hb_ts, col_lease_exp)
    INTO _msg;

    IF _msg IS NOT NULL THEN
      RAISE EXCEPTION 'Phase47 invariant failure: running task heartbeat is missing/out-of-range vs lease';
    END IF;
  END IF;

END $$;

SELECT 'OK: Phase 47 decision correctness invariants clean.' AS phase47_status;
