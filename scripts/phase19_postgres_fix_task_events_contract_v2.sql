-- Postgres lane: keep legacy task_events.payload as TEXT.
-- Add optional jsonb mirror payload_jsonb + other additive columns.

alter table task_events add column if not exists task_id text;
alter table task_events add column if not exists ts bigint;
alter table task_events add column if not exists run_id text;
alter table task_events add column if not exists actor text;

-- payload_jsonb mirror (do NOT redefine payload; it's legacy TEXT)
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='task_events' and column_name='payload_jsonb'
  ) then
    alter table task_events add column payload_jsonb jsonb null;
  end if;
end $$;

-- best-effort parse legacy payload TEXT into payload_jsonb
update task_events
set payload_jsonb = case
  when payload_jsonb is not null then payload_jsonb
  when payload is null then null
  when left(payload,1)='{' then payload::jsonb
  when left(payload,1)='[' then payload::jsonb
  else jsonb_build_object('text', payload)
end
where payload_jsonb is null;

create index if not exists idx_task_events_task_id on task_events(task_id);
create index if not exists idx_task_events_kind    on task_events(kind);
