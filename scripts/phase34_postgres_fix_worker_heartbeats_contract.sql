-- Phase34 contract fix:
-- Phase34 heartbeat/reclaim SQL uses worker_heartbeats(owner, last_seen_at).
-- Our earlier table had last_beat_ms BIGINT NOT NULL, which breaks INSERT(owner,last_seen_at).

alter table worker_heartbeats
  alter column last_beat_ms drop not null;

-- Optional: keep the legacy column useful by syncing it forward.
update worker_heartbeats
  set last_beat_ms = greatest(coalesce(last_beat_ms,0), coalesce(last_seen_at,0))
where last_seen_at is not null;

