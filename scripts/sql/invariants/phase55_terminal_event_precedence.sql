-- Phase 55 (SQL-first): terminal_event precedence + non-regression
-- Invariant:
--   For each task_id, the tasks.terminal_event_* fields must match the FIRST terminal event in the events table.
--   This asserts terminal precedence even if later non-terminal events arrive (e.g., heartbeats), and prevents regressions.

DO $$
DECLARE
  events_reg regclass;
  tasks_reg  regclass;
  violations bigint := 0;
BEGIN
  -- Resolve canonical tables without guessing UI/JS shapes.
  -- Try common names; fail closed if not present.
  events_reg := COALESCE(
    to_regclass('public.task_events'),
    to_regclass('public.tasks_events'),
    to_regclass('public.events'),
    to_regclass('public.task_event')
  );

  tasks_reg := COALESCE(
    to_regclass('public.tasks'),
    to_regclass('public.task')
  );

  IF events_reg IS NULL THEN
    RAISE EXCEPTION 'Phase55 invariant: cannot find events table (tried task_events/tasks_events/events/task_event)';
  END IF;

  IF tasks_reg IS NULL THEN
    RAISE EXCEPTION 'Phase55 invariant: cannot find tasks table (tried tasks/task)';
  END IF;

  -- Verify required columns exist (fail closed).
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema='public'
      AND table_name = split_part(events_reg::text,'.',2)
      AND column_name IN ('task_id','event_ts','event_kind','is_terminal')
    GROUP BY table_schema, table_name
    HAVING COUNT(DISTINCT column_name)=4
  ) THEN
    RAISE EXCEPTION 'Phase55 invariant: events table % missing one of (task_id,event_ts,event_kind,is_terminal)', events_reg;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema='public'
      AND table_name = split_part(tasks_reg::text,'.',2)
      AND column_name IN ('task_id','terminal_event_ts','terminal_event_kind')
    GROUP BY table_schema, table_name
    HAVING COUNT(DISTINCT column_name)=3
  ) THEN
    RAISE EXCEPTION 'Phase55 invariant: tasks table % missing one of (task_id,terminal_event_ts,terminal_event_kind)', tasks_reg;
  END IF;

  -- Compute the first terminal event per task_id and require tasks.* to match it exactly.
  EXECUTE format($q$
    WITH first_terminal AS (
      SELECT
        e.task_id,
        (ARRAY_AGG(e.event_ts   ORDER BY e.event_ts ASC, e.event_kind ASC))[1] AS first_terminal_ts,
        (ARRAY_AGG(e.event_kind ORDER BY e.event_ts ASC, e.event_kind ASC))[1] AS first_terminal_kind
      FROM %s e
      WHERE e.is_terminal = TRUE
      GROUP BY e.task_id
    ),
    mismatches AS (
      SELECT
        t.task_id,
        t.terminal_event_ts,
        t.terminal_event_kind,
        ft.first_terminal_ts,
        ft.first_terminal_kind
      FROM %s t
      JOIN first_terminal ft USING (task_id)
      WHERE
        t.terminal_event_ts  IS DISTINCT FROM ft.first_terminal_ts
        OR t.terminal_event_kind IS DISTINCT FROM ft.first_terminal_kind
    )
    SELECT COUNT(*) FROM mismatches
  $q$, events_reg, tasks_reg)
  INTO violations;

  IF violations <> 0 THEN
    RAISE EXCEPTION 'Phase55 invariant failed: % task(s) have terminal_event mismatch vs first terminal event', violations;
  END IF;

  -- Also ensure terminal_event_ts/kind are paired (no half-null).
  EXECUTE format($q$
    SELECT COUNT(*)
    FROM %s t
    WHERE
      (t.terminal_event_ts IS NULL) <> (t.terminal_event_kind IS NULL)
  $q$, tasks_reg)
  INTO violations;

  IF violations <> 0 THEN
    RAISE EXCEPTION 'Phase55 invariant failed: % task(s) have half-null terminal_event fields', violations;
  END IF;

  RAISE NOTICE 'Phase55 invariant OK: terminal precedence + pairing validated.';
END
$$;
