-- Inputs: $1=owner
INSERT INTO worker_heartbeats(owner, last_seen_at)
VALUES ($1, (extract(epoch from now())*1000)::bigint)
ON CONFLICT (owner) DO UPDATE
SET last_seen_at = EXCLUDED.last_seen_at;
