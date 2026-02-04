-- Postgres lane fix: workers emit task_events(task_id, kind, ts, payload, ...).
-- Current Postgres task_events table is missing task_id.

alter table task_events
  add column if not exists task_id text;

-- If table is empty (yours currently is), we can safely make it NOT NULL after add.
do $$
begin
  if (select count(*) from task_events) = 0 then
    alter table task_events alter column task_id set not null;
  end if;
exception when others then
  -- stay non-fatal; we'll keep nullable if constraint can't be set
  null;
end $$;

create index if not exists idx_task_events_task_id on task_events(task_id);
