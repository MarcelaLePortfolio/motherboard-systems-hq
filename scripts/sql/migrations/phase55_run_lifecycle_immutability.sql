BEGIN;

ALTER TABLE public.task_events
  ADD COLUMN IF NOT EXISTS is_terminal boolean NOT NULL DEFAULT FALSE;

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS terminal_event_ts bigint,
  ADD COLUMN IF NOT EXISTS terminal_event_kind text;

WITH terminal_kinds(kind) AS (
  VALUES
    ('task.completed')
),
marked AS (
  UPDATE public.task_events e
  SET is_terminal = EXISTS (SELECT 1 FROM terminal_kinds tk WHERE tk.kind = e.kind)
  RETURNING 1
),
first_terminal AS (
  SELECT
    e.task_id,
    (ARRAY_AGG(e.ts   ORDER BY e.ts ASC, e.kind ASC))[1] AS first_terminal_ts,
    (ARRAY_AGG(e.kind ORDER BY e.ts ASC, e.kind ASC))[1] AS first_terminal_kind
  FROM public.task_events e
  WHERE e.is_terminal = TRUE
  GROUP BY e.task_id
),
backfilled AS (
  UPDATE public.tasks t
  SET
    terminal_event_ts   = ft.first_terminal_ts,
    terminal_event_kind = ft.first_terminal_kind
  FROM first_terminal ft
  WHERE ft.task_id = t.task_id
  RETURNING 1
)
SELECT 1;

COMMIT;
