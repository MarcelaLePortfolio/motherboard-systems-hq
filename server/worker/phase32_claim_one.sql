WITH candidate AS (
  SELECT id
  FROM tasks
  WHERE status IN ('queued','delegated')
    AND attempts < max_attempts
    AND (next_run_at IS NULL OR next_run_at <= now())
  ORDER BY id ASC
  FOR UPDATE SKIP LOCKED
  LIMIT 1
)
UPDATE tasks t
SET status = 'running',
    run_id = $1,
    actor  = $2,
    updated_at = now()
FROM candidate c
WHERE t.id = c.id
RETURNING t.*;
