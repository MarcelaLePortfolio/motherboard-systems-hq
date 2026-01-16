-- phase27: claim one queued task (conditional ORDER BY priority if present)
with cte as (
  select id
  from tasks
  where status = 'queued'
  order by id asc
  for update skip locked
  limit 1
)
update tasks t
set
  status = 'running',
  updated_at = now()
from cte
where t.id = cte.id
returning t.*;
