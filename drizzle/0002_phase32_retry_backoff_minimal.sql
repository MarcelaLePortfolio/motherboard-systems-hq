-- phase32: minimal retry/backoff semantics (SQL-first)
BEGIN;
ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS attempts        integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS max_attempts    integer NOT NULL DEFAULT 5,
  ADD COLUMN IF NOT EXISTS next_run_at     timestamptz,
  ADD COLUMN IF NOT EXISTS last_error      text,
  ADD COLUMN IF NOT EXISTS last_error_at   timestamptz;
CREATE INDEX IF NOT EXISTS tasks_claim_ready_idx
  ON tasks (status, next_run_at, id);
COMMIT;
