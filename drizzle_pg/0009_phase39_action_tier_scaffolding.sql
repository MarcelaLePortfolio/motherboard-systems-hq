-- Phase 39: Action Tier scaffolding (structural value-alignment)
-- Adds tasks.action_tier (default 'A') and optional disclosure fields.
-- No UI changes. Existing flows remain Tier A.

ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS action_tier TEXT NOT NULL DEFAULT 'A';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'tasks_action_tier_allowed'
  ) THEN
    ALTER TABLE tasks
      ADD CONSTRAINT tasks_action_tier_allowed
      CHECK (action_tier IN ('A','B','C'));
  END IF;
END $$;

ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS tier_disclosure_title TEXT,
  ADD COLUMN IF NOT EXISTS tier_disclosure_body  TEXT;

-- Disclosure validation is enforced at API boundary for B/C to avoid breaking inserts.
