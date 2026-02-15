-- Phase 39 DB Repair (idempotent):
-- - ensure tasks.notes exists (dashboard + routes expect it)
-- - ensure tasks.failed_at exists (phase31_7 guard expects it)
-- - repair task_events.task_id numeric rows so task_events_task_id_not_numeric can be applied
-- - (re)apply constraints in a safe, idempotent way

DO $$
BEGIN
  -- tasks.notes
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema='public' AND table_name='tasks' AND column_name='notes'
  ) THEN
    ALTER TABLE public.tasks ADD COLUMN notes text;
  END IF;

  -- tasks.failed_at
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema='public' AND table_name='tasks' AND column_name='failed_at'
  ) THEN
    ALTER TABLE public.tasks ADD COLUMN failed_at timestamptz;
  END IF;
END
$$;

-- Repair numeric task_id rows (e.g., '16') into non-numeric form (e.g., 't16')
UPDATE public.task_events
SET task_id = 't' || task_id
WHERE task_id ~ '^[0-9]+$';

DO $$
BEGIN
  -- task_events_task_id_not_numeric
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname='task_events_task_id_not_numeric'
  ) THEN
    ALTER TABLE public.task_events
    ADD CONSTRAINT task_events_task_id_not_numeric
    CHECK (task_id !~ '^[0-9]+$');
  END IF;

  -- tasks_failed_at_matches_status (phase31_7 guard expects failed_at)
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname='tasks_failed_at_matches_status'
  ) THEN
    ALTER TABLE public.tasks
    ADD CONSTRAINT tasks_failed_at_matches_status
    CHECK (
      (status = 'failed' AND failed_at IS NOT NULL)
      OR
      (status <> 'failed' AND failed_at IS NULL)
    );
  END IF;
END
$$;
