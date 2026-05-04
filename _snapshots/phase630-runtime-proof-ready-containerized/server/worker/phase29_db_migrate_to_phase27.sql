begin;

-- 1) tasks: add canonical columns if missing
alter table tasks add column if not exists payload jsonb null;
alter table tasks add column if not exists attempts integer not null default 0;
alter table tasks add column if not exists next_run_at timestamptz null;

-- 2) tasks: best-effort backfill payload from meta if present
do $$
begin
  if exists (select 1 from information_schema.columns where table_name='tasks' and column_name='meta')
     and exists (select 1 from information_schema.columns where table_name='tasks' and column_name='payload') then
    update tasks
      set payload = coalesce(payload, meta)
    where payload is null and meta is not null;
  end if;
end $$;

-- 3) tasks: best-effort backfill attempts from attempt if present
do $$
begin
  if exists (select 1 from information_schema.columns where table_name='tasks' and column_name='attempt') then
    update tasks
      set attempts = greatest(attempts, attempt)
    where attempt is not null;
  end if;
end $$;

-- 4) tasks: best-effort backfill next_run_at from available_at if present
do $$
begin
  if exists (select 1 from information_schema.columns where table_name='tasks' and column_name='available_at') then
    update tasks
      set next_run_at = coalesce(next_run_at, available_at)
    where next_run_at is null and available_at is not null;
  end if;
end $$;

-- 5) task_events: ensure columns exist
alter table task_events add column if not exists run_id text null;
alter table task_events add column if not exists actor text null;

-- 6) task_events.payload: if it's TEXT, add payload_jsonb and keep payload text (no destructive alter here)
-- We'll add a new jsonb column and have new code write jsonb while preserving legacy text.
do $$
begin
  if not exists (select 1 from information_schema.columns where table_name='task_events' and column_name='payload_jsonb') then
    alter table task_events add column payload_jsonb jsonb null;
  end if;
end $$;

-- best-effort parse legacy payload text into jsonb where possible
update task_events
set payload_jsonb = case
  when payload_jsonb is not null then payload_jsonb
  else
    case
      when payload is null then null
      when left(payload,1)='{' then payload::jsonb
      when left(payload,1)='[' then payload::jsonb
      else jsonb_build_object('text', payload)
    end
end
where payload_jsonb is null;

create index if not exists idx_task_events_task_id on task_events(task_id);
create index if not exists idx_task_events_kind on task_events(kind);
create index if not exists idx_tasks_status_next_run on tasks(status, next_run_at);

commit;
