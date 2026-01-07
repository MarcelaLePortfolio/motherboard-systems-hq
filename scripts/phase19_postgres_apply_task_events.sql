-- Phase 19: Postgres task_events schema (repeatable)
create table if not exists public.task_events (
  id bigserial primary key,
  kind text not null,
  payload text not null,
  created_at text default (now()::timestamptz)::text
);

-- backfill then enforce (safe if already enforced)
update public.task_events set kind = 'unknown' where kind is null;
update public.task_events set payload = '{}' where payload is null;

alter table public.task_events
  alter column kind set not null,
  alter column payload set not null;
