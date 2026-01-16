-- phase27_claim_one.sql
-- Params:
--   $1 = lease_owner (text)
--   $2 = lease_expires_at (timestamptz)

with c as (
  select id
  from tasks
  where
    (coalesce(status,'') in ('created','queued','requeued') or status is null)
    and (coalesce(available_at, to_timestamp(0)) <= now())
  order by coalesce(priority,0) desc, id asc
  for update skip locked
  limit 1
)
update tasks t
set
  status = 'running',
  run_id = coalesce(t.run_id, gen_random_uuid()::text),
  lease_owner = $1,
  lease_expires_at = $2,
  updated_at = now()
from c
where t.id = c.id
returning t.*;
