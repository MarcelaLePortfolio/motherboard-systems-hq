WITH updated AS (
  UPDATE tasks
     SET status = 'completed',
         completed_at = NOW()
   WHERE task_id = $1
     AND status = 'running'
     AND claimed_by = $2
     AND lease_epoch = $3
  RETURNING task_id
)
SELECT task_id FROM updated;
