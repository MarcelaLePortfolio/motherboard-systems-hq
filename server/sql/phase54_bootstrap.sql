-- Phase 54 CI bootstrap: ensure baseline tables exist for dashboard startup.
-- Keep minimal and idempotent.

create table if not exists tasks (
  id bigserial primary key,
  task_id text,
  status text,
  kind text,
  payload jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists tasks_task_id_idx on tasks(task_id);

-- task_events: minimal table for dashboard + workers
create table if not exists task_events (
  id bigserial primary key,
  task_id text,
  kind text,
  actor text,
  payload jsonb,
  created_at timestamptz default now()
);

create index if not exists task_events_task_id_idx on task_events(task_id);
create index if not exists task_events_created_at_idx on task_events(created_at);
