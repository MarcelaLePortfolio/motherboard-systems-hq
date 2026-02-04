-- Baseline worker_heartbeats table for Phase34 reclaim logic (Postgres lane).

create table if not exists worker_heartbeats (
  owner        text primary key,
  last_beat_ms bigint not null,
  run_id       text null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists idx_worker_heartbeats_last_beat_ms
  on worker_heartbeats(last_beat_ms);
