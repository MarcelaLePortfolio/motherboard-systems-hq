-- Baseline tasks table for Postgres lane (required before Phase29/Phase35 migrations).
-- Contract: workers/phase34_claim_one_pg.sql expects:
--   status, claimed_by, claimed_at, lease_expires_at, lease_epoch
-- Phase29 migration expects:
--   payload, attempts, next_run_at (and index on status,next_run_at)

create table if not exists tasks (
  id               bigserial primary key,

  -- optional stable external id (legacy-friendly)
  task_id          text null,

  title            text not null,
  agent            text null,

  status           text not null default 'created',
  source           text null,
  trace_id         text null,

  meta             jsonb null,
  payload          jsonb null,

  attempts         integer not null default 0,
  next_run_at      timestamptz null,

  claimed_by       text null,
  claimed_at       bigint null,

  lease_expires_at bigint null,
  lease_epoch      integer not null default 0,

  error            text null,

  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
-- Helpful indexes (safe if re-run)
create index if not exists idx_tasks_status_next_run on tasks(status, next_run_at);
create index if not exists idx_tasks_status_id          on tasks(status, id);
create index if not exists idx_tasks_created_at         on tasks(created_at);

-- Optional uniqueness if task_id is used (non-breaking if task_id stays null)
do $$
begin
  if not exists (
    select 1
    from pg_indexes
    where schemaname='public' and indexname='ux_tasks_task_id'
  ) then
    create unique index ux_tasks_task_id on tasks(task_id) where task_id is not null;
  end if;
end $$;
