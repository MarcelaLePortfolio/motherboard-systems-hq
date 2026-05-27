ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS lease_epoch BIGINT NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_tasks_claim_guard
  ON tasks (task_id, claimed_by, lease_epoch);
