-- Inputs: :task_id
UPDATE tasks
SET status='completed',
    lease_expires_at=NULL
WHERE id=:'task_id'::bigint
  AND status='running'
RETURNING id;
