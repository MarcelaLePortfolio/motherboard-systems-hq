UPDATE tasks
SET
  status = 'completed',
  completed_at = now(),
  failed_at = NULL,
  next_run_at = NULL,
  locked_by = NULL,
  lock_expires_at = NULL,
  updated_at = now()
WHERE id = $1
  AND status = 'running'
RETURNING *;
