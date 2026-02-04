-- Contract-friendly Postgres task_events shape (additive, non-destructive).

alter table task_events add column if not exists task_id text;
alter table task_events add column if not exists ts bigint;
alter table task_events add column if not exists kind text;
alter table task_events add column if not exists payload jsonb;
alter table task_events add column if not exists payload_jsonb jsonb;
alter table task_events add column if not exists run_id text;
alter table task_events add column if not exists actor text;

-- Prefer payload_jsonb if present; keep payload aligned.
update task_events
set payload_jsonb = coalesce(payload_jsonb, payload)
where payload_jsonb is null and payload is not null;

create index if not exists idx_task_events_task_id on task_events(task_id);
create index if not exists idx_task_events_kind on task_events(kind);
