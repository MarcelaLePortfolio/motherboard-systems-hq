-- Phase 55: Run lifecycle immutability — terminal_event precedence (SQL-first).
-- Goal:
--   For each task, tasks.terminal_event_* must match the earliest terminal task_event (by ts asc, kind asc).
-- Constraints:
--   No UI inference. Fail-closed if we cannot resolve required tables/columns.
-- Notes:
--   This script adapts to minor schema naming differences by selecting from an allowlisted set of column names.

DO $$
DECLARE
  events_reg regclass;
  tasks_reg  regclass;

  events_tbl text;
  tasks_tbl  text;

  ev_task_col text;
  ev_ts_col   text;
  ev_kind_col text;
  ev_term_col text;

  t_task_col  text;
  t_ts_col    text;
  t_kind_col  text;

  violations bigint := 0;

  -- helper: pick first existing column from allowlist
  FUNCTION pick_col(_tbl text, _candidates text[]) RETURNS text
  LANGUAGE plpgsql AS $f$
  DECLARE
    c text;
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
  END
  $f$;

BEGIN
  -- Resolve canonical tables without guessing UI/JS shapes.
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

  -- Extract plain table names (assume public schema).
  events_tbl := split_part(events_reg::text, '.', 2);
  tasks_tbl  := split_part(tasks_reg::text,  '.', 2);

  -- Allowlisted schema adaptations (SQL-first, fail-closed).
  ev_task_col := pick_col(events_tbl, ARRAY['task_id','taskId']);
  ev_ts_col   := pick_col(events_tbl, ARRAY['event_ts','event_ts_ms','event_ts_epoch','ts','ts_ms','created_at','created_at_ms']);
  ev_kind_col := pick_col(events_tbl, ARRAY['event_kind','kind','eventType','event_type']);
  ev_term_col := pick_col(events_tbl, ARRAY['is_terminal','isTerminal','terminal','is_terminal_event','isTerminalEvent']);

  t_task_col  := pick_col(tasks_tbl,  ARRAY['task_id','taskId']);
  t_ts_col    := pick_col(tasks_tbl,  ARRAY['terminal_event_ts','terminal_event_at','terminal_event_time','terminalEventTs','terminalEventAt']);
  t_kind_col  := pick_col(tasks_tbl,  ARRAY['terminal_event_kind','terminal_event_type','terminal_event','terminalEventKind','terminalEventType']);

  IF ev_task_col IS NULL OR ev_ts_col IS NULL OR ev_kind_col IS NULL OR ev_term_col IS NULL THEN
    RAISE EXCEPTION 'Phase55 invariant: events table % missing required cols; need task+ts+kind+terminal flag (allowlist task_id/taskId, event_ts/ts/created_at, event_kind/kind, is_terminal/terminal)', events_reg;
  END IF;

  IF t_task_col IS NULL OR t_ts_col IS NULL OR t_kind_col IS NULL THEN
    RAISE EXCEPTION 'Phase55 invariant: tasks table % missing required cols; need task_id + terminal_event_ts + terminal_event_kind (allowlist includes terminal_event_at/type variants)', tasks_reg;
  END IF;

  -- Compute the first terminal event per task and require tasks.* to match exactly.
  EXECUTE format($q$
    WITH first_terminal AS (
      SELECT
        e.%1$I AS task_id,
        (ARRAY_AGG(e.%2$I ORDER BY e.%2$I ASC, e.%3$I ASC))[1] AS first_terminal_ts,
        (ARRAY_AGG(e.%3$I ORDER BY e.%2$I ASC, e.%3$I ASC))[1] AS first_terminal_kind
      FROM %4$s e
      WHERE e.%5$I = TRUE
      GROUP BY e.%1$I
    ),
    mismatches AS (
      SELECT
        t.%6$I AS task_id,
        t.%7$I AS terminal_event_ts,
        t.%8$I AS terminal_event_kind,
        ft.first_terminal_ts,
        ft.first_terminal_kind
      FROM %9$s t
      JOIN first_terminal ft
        ON ft.task_id = t.%6$I
      WHERE
        t.%7$I IS DISTINCT FROM ft.first_terminal_ts
        OR t.%8$I IS DISTINCT FROM ft.first_terminal_kind
    )
    SELECT COUNT(*) FROM mismatches
  $q$,
    ev_task_col, ev_ts_col, ev_kind_col, events_reg, ev_term_col,
    t_task_col, t_ts_col, t_kind_col, tasks_reg
  )
  INTO violations;

  IF violations <> 0 THEN
    RAISE EXCEPTION 'Phase55 invariant failed: % task(s) have terminal_event mismatch vs first terminal event', violations;
  END IF;

  -- Ensure terminal_event_ts/kind are paired (no half-null).
  EXECUTE format($q$
    SELECT COUNT(*)
    FROM %1$s t
    WHERE (t.%2$I IS NULL) <> (t.%3$I IS NULL)
  $q$, tasks_reg, t_ts_col, t_kind_col)
  INTO violations;

  IF violations <> 0 THEN
    RAISE EXCEPTION 'Phase55 invariant failed: % task(s) have half-null terminal_event fields', violations;
  END IF;

  RAISE NOTICE 'Phase55 invariant OK: terminal precedence + pairing validated (% %, % %).',
    events_reg, tasks_reg, ev_term_col, t_ts_col;
END
$$;
