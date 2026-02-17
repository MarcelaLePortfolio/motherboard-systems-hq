-- Phase 39: Claim-one with Tier enforcement gate
--
-- Behavior:
--  - If a queued Tier B/C task exists, return it as a REFUSE row (no mutation).
--  - Otherwise, claim a queued Tier A (or NULL) task via UPDATE ... RETURNING.
--
-- Output is a single row with a gate_action discriminator:
--   gate_action = 'REFUSE' | 'CLAIM'
--
-- NOTE: Intended to be used via PHASE32_CLAIM_ONE_SQL indirection.

WITH disallowed AS (
  SELECT t.id, t.task_id, t.title, t.action_tier
  FROM tasks t
  WHERE t.status = 'queued'
    AND t.action_tier IN ('B','C')
  ORDER BY t.id
  FOR UPDATE SKIP LOCKED
  LIMIT 1
),
allowed_pick AS (
  SELECT t.id
  FROM tasks t
  WHERE t.status = 'queued'
    AND (t.action_tier IS NULL OR t.action_tier = 'A')
    AND NOT EXISTS (SELECT 1 FROM disallowed)
  ORDER BY t.id
  FOR UPDATE SKIP LOCKED
  LIMIT 1
),
claimed AS (
  UPDATE tasks t
  SET status     = 'delegated',
      claimed_by = COALESCE(current_setting('app.worker_id', true), t.claimed_by),
      claimed_at = NOW()
  WHERE t.id = (SELECT id FROM allowed_pick)
  RETURNING t.id, t.task_id, t.title, t.action_tier
)
SELECT
  'REFUSE'::text AS gate_action,
  d.id,
  d.task_id,
  d.title,
  d.action_tier
FROM disallowed d
UNION ALL
SELECT
  'CLAIM'::text AS gate_action,
  c.id,
  c.task_id,
  c.title,
  c.action_tier
FROM claimed c;
