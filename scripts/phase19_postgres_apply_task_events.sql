-- Phase 19: Postgres task_events schema (fully idempotent)
create table if not exists public.task_events (
  id bigserial primary key,
  kind text,
  payload text,
  created_at text default (now()::timestamptz)::text
);

-- backfill nulls
update public.task_events set kind = 'unknown' where kind is null;
update public.task_events set payload = '{}' where payload is null;

-- enforce not-null only if needed
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='task_events'
      and column_name='kind' and is_nullable='YES'
  ) then
    alter table public.task_events alter column kind set not null;
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='task_events'
      and column_name='payload' and is_nullable='YES'
  ) then
    alter table public.task_events alter column payload set not null;
  end if;
end $$;
