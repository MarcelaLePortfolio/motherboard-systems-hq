update tasks
set
  status = 'completed',
  updated_at = now(),
  locked_by = null,
  lock_expires_at = null
where id = $1
returning *;
