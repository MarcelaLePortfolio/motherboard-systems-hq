UPDATE tasks
   SET status = 'created',
       claimed_by = NULL,
       claimed_at = NULL,
       lease_expires_at = NULL,
       lease_epoch = lease_epoch + 1
 WHERE status = 'running'
   AND lease_expires_at IS NOT NULL
   AND lease_expires_at <= NOW()
 RETURNING task_id;
