-- Inputs: $1 = stale_heartbeat_ms (e.g., 30000)
WITH params AS (
  SELECT $1::bigint AS stale_heartbeat_ms,
         (extract(epoch from now())*1000)::bigint AS now_ms
),
dead AS (
  SELECT wh.owner
  FROM worker_heartbeats wh, params p
  WHERE wh.last_seen_at < (p.now_ms - p.stale_heartbeat_ms)
),
r AS (
  UPDATE tasks t
  SET status='created',
      claimed_by=NULL,
      claimed_at=NULL,
      lease_expires_at=NULL,
      lease_epoch=COALESCE(t.lease_epoch,0)+1
  WHERE t.status='running'
    AND (
      (t.lease_expires_at IS NOT NULL AND t.lease_expires_at <= (extract(epoch from now())*1000)::bigint)
      OR (t.claimed_by IS NOT NULL AND t.claimed_by IN (SELECT owner FROM dead))
      OR (t.claimed_by IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM worker_heartbeats wh2 WHERE wh2.owner = t.claimed_by
          ))
    )
  RETURNING t.id
)
SELECT count(*)::bigint AS reclaimed FROM r;
