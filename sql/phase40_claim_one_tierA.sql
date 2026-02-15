-- Phase 40 — SQL-first Tier A claim gate (canonical claim SQL)
--
-- Contract:
-- - Only Tier A (action_tier='A') tasks are claimable via this path.
-- - Deterministic ordering is explicit.
-- - Concurrency-safe selection (FOR UPDATE SKIP LOCKED).
-- - No JS-derived state.
--
-- Inputs (psql):
--   :claimed_by
--   :run_id
--
-- NOTE: This claims ONE task by moving queued -> running. It is intentionally minimal:
-- it does not redesign leases or event emission; it is a structural gate at the claim boundary.

WITH candidate AS (
  SELECT id
  FROM tasks
  WHERE status = 'queued'
    AND COALESCE(action_tier, 'A') = 'A'
    AND attempts < COALESCE(max_attempts, 2147483647)
  ORDER BY id ASC
  FOR UPDATE SKIP LOCKED
  LIMIT 1
)
UPDATE tasks t
SET status    = 'running',
    claimed_by = :'claimed_by',
    run_id    = COALESCE(t.run_id, :'run_id')
FROM candidate c
WHERE t.id = c.id
RETURNING
  t.id,
  t.task_id,
  t.title,
  t.status,
  t.action_tier,
  t.attempts,
  t.max_attempts,
  t.claimed_by,
  t.run_id;
