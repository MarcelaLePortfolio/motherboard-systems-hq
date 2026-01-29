-- Inputs: $1=task_id, $2=errStr
UPDATE tasks
SET status='failed',
    lease_expires_at=NULL
WHERE id=$1::bigint
  AND status='running'
RETURNING id;
