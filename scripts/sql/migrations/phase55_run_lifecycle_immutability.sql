BEGIN;

-- Phase 55: run lifecycle immutability
-- Goal: tasks.terminal_event_ts/kind MUST reflect the FIRST terminal event in task_events (deterministic precedence).

-- Ensure required columns exist (idempotent).
ALTER TABLE public.task_events
  ADD COLUMN IF NOT EXISTS is_terminal boolean;

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS terminal_event_ts bigint,
  ADD COLUMN IF NOT EXISTS terminal_event_kind text;

-- Backfill tasks terminal fields from first terminal event per task.
-- Deterministic tie-break: ORDER BY ts ASC, kind ASC.
WITH first_terminal AS (
  SELECT
    e.task_id,
    (ARRAY_AGG(e.ts   ORDER BY e.ts ASC, e.kind ASC))[1] AS first_terminal_ts,
    (ARRAY_AGG(e.kind ORDER BY e.ts ASC, e.kind ASC))[1] AS first_terminal_kind
  FROM public.task_events e
  WHERE e.is_terminal = TRUE
  GROUP BY e.task_id
),
to_fix AS (
  SELECT
    t.task_id,
    ft.first_terminal_ts,
    ft.first_terminal_kind
  FROM public.tasks t
  JOIN first_terminal ft
    ON ft.task_id = t.task_id
  WHERE
    t.terminal_event_ts   IS DISTINCT FROM ft.first_terminal_ts
    OR t.terminal_event_kind IS DISTINCT FROM ft.first_terminal_kind
)
UPDATE public.tasks t
SET
  terminal_event_ts   = f.first_terminal_ts,
  terminal_event_kind = f.first_terminal_kind
FROM to_fix f
WHERE t.task_id = f.task_id;

COMMIT;
