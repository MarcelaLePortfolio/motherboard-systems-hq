-- phase27: claim one queued task
-- Inputs:
--   $1 = worker_id/owner (text)
with candidate as (
  select id
  from tasks
  where status = 'queued'
    and (available_at is null or available_at <= now())
    and (
      locked_by is null
      or lock_expires_at is null
      or lock_expires_at <= now()
    )
  order by
    coalesce(available_at, created_at) asc,
    id asc
  for update skip locked
  limit 1
),
updated as (
  update tasks t
  set
    status = 'running',
    locked_by = $1::text,
    lock_expires_at = now() + interval '10 minutes',
    updated_at = now(),
    attempt = attempt + 1
  from candidate c
  where t.id = c.id
  returning t.*
)
select * from updated;
