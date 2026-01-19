-- params:
-- $1 id (int)
-- $2 status ('queued' | 'failed')
-- $3 next_attempt (int)
-- $4 next_available_at (timestamptz, nullable)
-- $5 last_error (jsonb)

update tasks
set status = $2,
    attempt = $3,
    attempts = $3,
    available_at = $4,
    next_run_at = $4,
    last_error = $5::jsonb,
    failed_at = case when $2 = 'failed' then now() else failed_at end,
    locked_by = null,
    lock_expires_at = null,
    updated_at = now()
where id = $1
returning *;
