-- Inputs:
--   $1 = task_id (text) OR id::text
--   $2 = worker_id (text)
update tasks
set
  status = 'completed',
  locked_by = null,
  lock_expires_at = null,
  updated_at = now()
where
  ((task_id = $1::text) or (id::text = $1::text))
  and (locked_by is null or locked_by = $2::text)
returning id, task_id, status, attempt, max_attempts;
