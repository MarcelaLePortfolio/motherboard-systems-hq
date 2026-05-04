-- PHASE 633 — SCHEMA PERSISTENCE (SAFE, NON-DESTRUCTIVE)

-- Ensure tasks table exists (no overwrite)
CREATE TABLE IF NOT EXISTS tasks (
  id SERIAL PRIMARY KEY
);

-- Add required columns safely (idempotent)
ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS next_run_at TIMESTAMP,
  ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP;

-- No drops, no mutations beyond additive schema
-- Maintains compatibility with existing worker contracts
