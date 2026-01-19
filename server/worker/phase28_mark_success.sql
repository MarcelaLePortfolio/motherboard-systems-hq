-- params:
-- $1 id (int)
update tasks
set status = 'completed',
    completed_at = now(),
    locked_by = null,
    lock_expires_at = null,
    updated_at = now()
where id = $1
returning *;
