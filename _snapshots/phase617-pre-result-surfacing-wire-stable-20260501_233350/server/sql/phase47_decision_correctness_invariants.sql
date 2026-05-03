/*
Phase 47 — Decision correctness invariants for claim/lease/reclaim.
SQL-first: fail-fast via RAISE EXCEPTION, schema-flex.
*/

DO $$
DECLARE
  col_task_id text;

  col_ev_id   text;
  col_ev_tid  text;
  col_ev_ts   text;
  col_ev_kind text;

  col_status      text;
  col_is_terminal text;
  col_lease_owner text;
  col_lease_exp   text;
  col_hb_ts       text;

  hit int;
BEGIN
  IF to_regclass('public.tasks') IS NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: missing table public.tasks';
  END IF;
  IF to_regclass('public.task_events') IS NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: missing table public.task_events';
  END IF;

  SELECT column_name INTO col_task_id
  FROM information_schema.columns
  WHERE table_schema='public' AND table_name='tasks' AND column_name='task_id'
  LIMIT 1;
  IF col_task_id IS NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: missing required column tasks.task_id';
  END IF;

  SELECT column_name INTO col_ev_id
  FROM information_schema.columns
  WHERE table_schema='public' AND table_name='task_events' AND column_name='id'
  LIMIT 1;

  SELECT column_name INTO col_ev_tid
  FROM information_schema.columns
  WHERE table_schema='public' AND table_name='task_events' AND column_name='task_id'
  LIMIT 1;

  SELECT column_name INTO col_ev_ts
  FROM information_schema.columns
  WHERE table_schema='public' AND table_name='task_events' AND column_name IN ('ts','created_at')
  ORDER BY CASE WHEN column_name='ts' THEN 0 ELSE 1 END
  LIMIT 1;

  SELECT column_name INTO col_ev_kind
  FROM information_schema.columns
  WHERE table_schema='public' AND table_name='task_events' AND column_name IN ('kind','event_kind')
  ORDER BY CASE WHEN column_name='kind' THEN 0 ELSE 1 END
  LIMIT 1;

  IF col_ev_id IS NULL OR col_ev_tid IS NULL OR col_ev_ts IS NULL OR col_ev_kind IS NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: task_events missing required columns';
  END IF;

  SELECT column_name INTO col_status
  FROM information_schema.columns
  WHERE table_schema='public' AND table_name='tasks' AND column_name IN ('task_status','status')
  ORDER BY CASE WHEN column_name='task_status' THEN 0 ELSE 1 END
  LIMIT 1;

  SELECT column_name INTO col_is_terminal
  FROM information_schema.columns
  WHERE table_schema='public' AND table_name='tasks' AND column_name IN ('is_terminal','terminal')
  ORDER BY CASE WHEN column_name='is_terminal' THEN 0 ELSE 1 END
  LIMIT 1;

  SELECT column_name INTO col_lease_owner
  FROM information_schema.columns
  WHERE table_schema='public' AND table_name='tasks' AND column_name IN ('lease_owner','lease_actor','lease_holder')
  ORDER BY CASE
    WHEN column_name='lease_owner' THEN 0
    WHEN column_name='lease_actor' THEN 1
    ELSE 2
  END
  LIMIT 1;

  SELECT column_name INTO col_lease_exp
  FROM information_schema.columns
  WHERE table_schema='public' AND table_name='tasks' AND column_name IN ('lease_expires_at','lease_until','lease_expires_ts')
  ORDER BY CASE
    WHEN column_name='lease_expires_at' THEN 0
    WHEN column_name='lease_until' THEN 1
    ELSE 2
  END
  LIMIT 1;

  SELECT column_name INTO col_hb_ts
  FROM information_schema.columns
  WHERE table_schema='public' AND table_name='tasks' AND column_name IN ('last_heartbeat_ts','heartbeat_ts','last_heartbeat_ms')
  ORDER BY CASE
    WHEN column_name='last_heartbeat_ts' THEN 0
    WHEN column_name='heartbeat_ts' THEN 1
    ELSE 2
  END
  LIMIT 1;

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
  INTO hit;

  IF hit IS NOT NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: task_events ordering violation';
  END IF;

  IF col_status IS NOT NULL AND col_lease_owner IS NOT NULL AND col_lease_exp IS NOT NULL THEN
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
    INTO hit;

    IF hit IS NOT NULL THEN
      RAISE EXCEPTION 'Phase47 invariant failure: running task missing/expired lease';
    END IF;
  END IF;

END $$;

SELECT 'OK: Phase 47 decision correctness invariants clean.' AS phase47_status;
