-- Inputs:
--   $1 = task_id (text) OR id::text
--   $2 = worker_id (text)
--   $3 = backoff_ms (int) computed by worker
--   $4 = last_error (jsonb)
--
-- Uses *current* attempt/max_attempts in row (attempt already bumped at claim time).
with row as (
  select id, task_id, attempt, max_attempts
  from tasks
  where ((task_id = $1::text) or (id::text = $1::text))
    and (locked_by is null or locked_by = $2::text)
  for update
),
upd as (
  update tasks t
  set
    status = case when row.attempt < row.max_attempts then 'queued' else 'failed' end,
    available_at = case
      when row.attempt < row.max_attempts then now() + (($3::int) * interval '1 millisecond')
      else t.available_at
    end,
    last_error = $4::jsonb,
    locked_by = null,
    lock_expires_at = null,
    updated_at = now()
  from row
  where t.id = row.id
  returning t.id, t.task_id, t.status, t.attempt, t.max_attempts, t.available_at
)
select * from upd;
