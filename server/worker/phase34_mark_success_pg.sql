-- Inputs: $1=task_id
UPDATE tasks
SET status='completed',
    lease_expires_at=NULL
WHERE id=$1::bigint
  AND status='running'
RETURNING id;
