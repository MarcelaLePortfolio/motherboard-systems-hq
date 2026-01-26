UPDATE tasks
SET
  status = 'completed',
  completed_at = now(),
  failed_at = NULL,
  updated_at = now()
WHERE id = $1
  AND status = 'running'
RETURNING *;
