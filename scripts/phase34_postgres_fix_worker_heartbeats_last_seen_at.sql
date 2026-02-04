-- Phase34 fix: align worker_heartbeats schema with Phase34 SQL (expects last_seen_at bigint).

alter table worker_heartbeats
  add column if not exists last_seen_at bigint not null default 0;

-- Best-effort backfill from previous column if it exists (yours: last_beat_ms).
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='worker_heartbeats' and column_name='last_beat_ms'
  ) then
    update worker_heartbeats
      set last_seen_at = greatest(last_seen_at, coalesce(last_beat_ms, 0));
  end if;
end $$;

create index if not exists idx_worker_heartbeats_last_seen_at
  on worker_heartbeats(last_seen_at);
