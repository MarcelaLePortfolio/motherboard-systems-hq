-- params:
-- $1 run_id (text)
-- $2 owner/locked_by (text)

with picked as (
  select id
  from tasks
  where status = 'queued'
    and (available_at is null or available_at <= now())
    and (lock_expires_at is null or lock_expires_at <= now())
  order by id asc
  for update skip locked
  limit 1
)
update tasks t
set status = 'running',
    run_id = $1,
    locked_by = $2,
    lock_expires_at = now() + interval '5 minutes',
    updated_at = now()
from picked
where t.id = picked.id
returning t.*;
