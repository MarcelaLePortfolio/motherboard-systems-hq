/*
Phase 47 — Decision correctness invariants for claim/lease/reclaim.
SQL-first: fail-fast via RAISE EXCEPTION.

Assumptions (guarded):
- tasks table exists with task_id, task_status, is_terminal, lease_owner, lease_expires_at, last_heartbeat_ts
- task_events table exists with id, task_id, ts, kind, actor, payload
- run_view may exist (optional); not required.

If some columns are missing, this script fails with a clear error so we don't "pass" on partial coverage.
*/

DO $$
DECLARE
  _missing text[];
BEGIN
  -- --- required tables ---
  IF to_regclass('public.tasks') IS NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: missing table public.tasks';
  END IF;
  IF to_regclass('public.task_events') IS NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: missing table public.task_events';
  END IF;

  -- --- required columns: tasks ---
  _missing := ARRAY[]::text[];
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='tasks' AND column_name='task_id') THEN _missing := array_append(_missing,'tasks.task_id'); END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='tasks' AND column_name='task_status') THEN _missing := array_append(_missing,'tasks.task_status'); END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='tasks' AND column_name='is_terminal') THEN _missing := array_append(_missing,'tasks.is_terminal'); END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='tasks' AND column_name='lease_owner') THEN _missing := array_append(_missing,'tasks.lease_owner'); END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='tasks' AND column_name='lease_expires_at') THEN _missing := array_append(_missing,'tasks.lease_expires_at'); END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='tasks' AND column_name='last_heartbeat_ts') THEN _missing := array_append(_missing,'tasks.last_heartbeat_ts'); END IF;

  IF array_length(_missing,1) IS NOT NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: missing required columns: %', array_to_string(_missing, ', ');
  END IF;

  -- --- required columns: task_events ---
  _missing := ARRAY[]::text[];
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='task_events' AND column_name='id') THEN _missing := array_append(_missing,'task_events.id'); END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='task_events' AND column_name='task_id') THEN _missing := array_append(_missing,'task_events.task_id'); END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='task_events' AND column_name='ts') THEN _missing := array_append(_missing,'task_events.ts'); END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='task_events' AND column_name='kind') THEN _missing := array_append(_missing,'task_events.kind'); END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='task_events' AND column_name='actor') THEN _missing := array_append(_missing,'task_events.actor'); END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='task_events' AND column_name='payload') THEN _missing := array_append(_missing,'task_events.payload'); END IF;

  IF array_length(_missing,1) IS NOT NULL THEN
    RAISE EXCEPTION 'Phase47 invariant failure: missing required columns: %', array_to_string(_missing, ', ');
  END IF;

  -- ---------------------------------------------------------------------------
  -- Invariant A: task_events ordering is strictly monotone per task_id by (ts, id)
  -- ---------------------------------------------------------------------------
  IF EXISTS (
    WITH w AS (
      SELECT
        task_id,
        ts,
        id,
        lag(ts) OVER (PARTITION BY task_id ORDER BY ts ASC, id ASC) AS prev_ts,
        lag(id) OVER (PARTITION BY task_id ORDER BY ts ASC, id ASC) AS prev_id
      FROM public.task_events
    )
    SELECT 1
    FROM w
    WHERE prev_ts IS NOT NULL
      AND (ts < prev_ts OR (ts = prev_ts AND id <= prev_id))
    LIMIT 1
  ) THEN
    RAISE EXCEPTION 'Phase47 invariant failure: task_events are not strictly increasing per task by (ts,id)';
  END IF;

  -- ---------------------------------------------------------------------------
  -- Invariant B: terminal status is consistent with terminal events (schema-agnostic by kind prefix)
  -- - If tasks.is_terminal=true then there exists SOME terminal-ish event kind.
  -- - If there exists terminal-ish event kind, tasks.is_terminal must be true.
  -- Terminal-ish: kind ILIKE 'task.terminated%' OR kind IN (task.completed, task.failed, task.canceled, task.cancelled)
  -- ---------------------------------------------------------------------------
  IF EXISTS (
    SELECT 1
    FROM public.tasks t
    WHERE t.is_terminal = TRUE
      AND NOT EXISTS (
        SELECT 1
        FROM public.task_events e
        WHERE e.task_id = t.task_id
          AND (
            e.kind ILIKE 'task.terminated%' OR
            e.kind IN ('task.completed','task.failed','task.canceled','task.cancelled')
          )
      )
    LIMIT 1
  ) THEN
    RAISE EXCEPTION 'Phase47 invariant failure: tasks.is_terminal=true without a terminal task_event';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.task_events e
    JOIN public.tasks t ON t.task_id = e.task_id
    WHERE (
      e.kind ILIKE 'task.terminated%' OR
      e.kind IN ('task.completed','task.failed','task.canceled','task.cancelled')
    )
      AND t.is_terminal = FALSE
    LIMIT 1
  ) THEN
    RAISE EXCEPTION 'Phase47 invariant failure: terminal task_event exists but tasks.is_terminal=false';
  END IF;

  -- ---------------------------------------------------------------------------
  -- Invariant C: lease fields must be present/valid for running tasks; must be absent for terminal tasks
  -- ---------------------------------------------------------------------------
  IF EXISTS (
    SELECT 1
    FROM public.tasks t
    WHERE t.task_status = 'running'
      AND (
        t.lease_owner IS NULL OR
        t.lease_expires_at IS NULL OR
        t.lease_expires_at <= now()
      )
    LIMIT 1
  ) THEN
    RAISE EXCEPTION 'Phase47 invariant failure: running task missing/expired lease (owner/expires_at)';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.tasks t
    WHERE t.is_terminal = TRUE
      AND (
        t.lease_owner IS NOT NULL OR
        t.lease_expires_at IS NOT NULL
      )
    LIMIT 1
  ) THEN
    RAISE EXCEPTION 'Phase47 invariant failure: terminal task retains lease fields';
  END IF;

  -- ---------------------------------------------------------------------------
  -- Invariant D: claim/lease/reclaim must be event-grounded and non-contradictory
  -- - For tasks in running state: there must exist a prior claim-ish or lease-ish event.
  -- - For each task: number of active leases cannot exceed 1 when inferred from events.
  -- Event inference (best-effort, strict enough to catch contradictions):
  -- - Acquire-ish: kind ILIKE 'lease.%acquir%' OR kind ILIKE 'task.claim%' OR kind ILIKE 'claim.%'
  -- - Release-ish: kind ILIKE 'lease.%releas%' OR kind ILIKE 'lease.%expired%' OR terminal-ish
  -- We compute "segments" by counting release markers and ensure at most 1 acquire marker in the last segment.
  -- ---------------------------------------------------------------------------
  IF EXISTS (
    SELECT 1
    FROM public.tasks t
    WHERE t.task_status = 'running'
      AND NOT EXISTS (
        SELECT 1
        FROM public.task_events e
        WHERE e.task_id = t.task_id
          AND (
            e.kind ILIKE 'lease.%acquir%' OR
            e.kind ILIKE 'task.claim%' OR
            e.kind ILIKE 'claim.%'
          )
      )
    LIMIT 1
  ) THEN
    RAISE EXCEPTION 'Phase47 invariant failure: running task has no claim/lease acquisition event';
  END IF;

  IF EXISTS (
    WITH marks AS (
      SELECT
        e.task_id,
        e.ts,
        e.id,
        CASE
          WHEN (e.kind ILIKE 'lease.%releas%' OR e.kind ILIKE 'lease.%expired%' OR e.kind ILIKE 'task.terminated%' OR e.kind IN ('task.completed','task.failed','task.canceled','task.cancelled'))
            THEN 1 ELSE 0
        END AS is_release,
        CASE
          WHEN (e.kind ILIKE 'lease.%acquir%' OR e.kind ILIKE 'task.claim%' OR e.kind ILIKE 'claim.%')
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
      SELECT DISTINCT ON (task_id)
        task_id,
        seg_id
      FROM seg
      ORDER BY task_id, seg_id DESC
    ),
    acquires_in_last AS (
      SELECT
        s.task_id,
        count(*) AS acquire_ct
      FROM seg s
      JOIN last_seg l ON l.task_id = s.task_id AND l.seg_id = s.seg_id
      WHERE s.is_acquire = 1
      GROUP BY s.task_id
    )
    SELECT 1
    FROM acquires_in_last
    WHERE acquire_ct > 1
    LIMIT 1
  ) THEN
    RAISE EXCEPTION 'Phase47 invariant failure: multiple lease/claim acquisitions without release in last segment (reclaim contradiction)';
  END IF;

  -- ---------------------------------------------------------------------------
  -- Invariant E: heartbeat sanity for running tasks (prevents "running forever" without liveness)
  -- - running tasks must have last_heartbeat_ts within a bounded window relative to lease_expires_at
  -- ---------------------------------------------------------------------------
  IF EXISTS (
    SELECT 1
    FROM public.tasks t
    WHERE t.task_status = 'running'
      AND (
        t.last_heartbeat_ts IS NULL OR
        t.last_heartbeat_ts > (extract(epoch from now()) * 1000)::bigint + 60000 OR
        t.last_heartbeat_ts < (extract(epoch from (t.lease_expires_at - interval '10 minutes')) * 1000)::bigint
      )
    LIMIT 1
  ) THEN
    RAISE EXCEPTION 'Phase47 invariant failure: running task heartbeat timestamp is missing or wildly out-of-range vs lease';
  END IF;

END $$;

-- If we get here, invariants are clean.
SELECT 'OK: Phase 47 decision correctness invariants clean.' AS phase47_status;
