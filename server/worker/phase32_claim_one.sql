/*
Phase 32 — claim one task (no-lease variant)
Params:
  $1 = run_id (text)
  $2 = owner  (text)
*/
WITH candidate AS (
  SELECT id
  FROM tasks
  WHERE status IN ('queued','delegated')
    AND attempts < COALESCE(max_attempts, 3)
    AND (next_run_at IS NULL OR next_run_at <= now())
  ORDER BY id ASC
  FOR UPDATE SKIP LOCKED
  LIMIT 1
)
UPDATE tasks t
SET
  status     = 'running',
  run_id     = $1,
  claimed_by = $2,
  task_id    = COALESCE(t.task_id, t.id::text)
FROM candidate c
WHERE t.id = c.id
RETURNING t.*;
