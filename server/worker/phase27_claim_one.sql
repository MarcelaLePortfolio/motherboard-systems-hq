-- Phase 27: claim exactly one task (queued eligible OR orphan running w/ expired lease)
-- Inputs:
--   $1 = worker_id (text)
--   $2 = lock_ms   (int)  e.g. 60000
-- Behavior:
--   - increments attempt
--   - sets status=running, locked_by, lock_expires_at
--   - respects available_at gate for queued
--   - allows reclaim for running if lock_expires_at < now()

with candidate as (
  select id
  from tasks
  where
    (
      status = 'queued'
      and (available_at is null or available_at <= now())
      and (lock_expires_at is null or lock_expires_at < now())
    )
    or
    (
      status = 'running'
      and lock_expires_at is not null
      and lock_expires_at < now()
    )
  order by id asc
  for update skip locked
  limit 1
)
update tasks t
set
  status = 'running',
  attempt = t.attempt + 1,
  locked_by = $1::text,
  lock_expires_at = now() + (($2::int) * interval '1 millisecond'),
  updated_at = now()
from candidate c
where t.id = c.id
returning
  t.id,
  t.task_id,
  t.status,
  t.agent,
  t.title,
  t.attempt,
  t.max_attempts,
  t.available_at,
  t.locked_by,
  t.lock_expires_at,
  t.meta;
