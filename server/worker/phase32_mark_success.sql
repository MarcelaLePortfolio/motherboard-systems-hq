UPDATE tasks
SET status = 'completed',
    updated_at = now()
WHERE id = $1
  AND status = 'running'
RETURNING *;
