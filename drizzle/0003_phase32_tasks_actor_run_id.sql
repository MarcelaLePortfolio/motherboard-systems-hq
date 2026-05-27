-- phase32: align tasks schema with worker claim contract (minimal, additive)
BEGIN;

ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS run_id text,
  ADD COLUMN IF NOT EXISTS actor  text;

COMMIT;
