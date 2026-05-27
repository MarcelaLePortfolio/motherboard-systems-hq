-- Phase35: minimal schema patch for verification (no scope creep beyond required columns)

ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS run_id text;

ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS actor text;

-- Optional: some code may look for these on task_events too; make this idempotent.
ALTER TABLE task_events
  ADD COLUMN IF NOT EXISTS run_id text;

ALTER TABLE task_events
  ADD COLUMN IF NOT EXISTS actor text;

ALTER TABLE task_events
  ADD COLUMN IF NOT EXISTS ts bigint;

ALTER TABLE task_events
  ADD COLUMN IF NOT EXISTS payload_jsonb jsonb;
