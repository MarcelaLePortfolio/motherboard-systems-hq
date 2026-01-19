update tasks
set
  status = 'failed',
  updated_at = now(),
  locked_by = null,
  lock_expires_at = null,
  last_error = case
    when $2 is null then last_error
    else ($2)::jsonb
  end
where id = $1
returning *;
