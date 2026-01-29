-- Inputs: $1=stale_heartbeat_ms
WITH dead AS (
  SELECT owner
  FROM worker_heartbeats
  WHERE last_seen_at < ((extract(epoch from now())*1000)::bigint - $1::bigint)
),
r AS (
  UPDATE tasks
  SET status='created',
      claimed_by=NULL,
      claimed_at=NULL,
      lease_expires_at=NULL,
      lease_epoch=COALESCE(lease_epoch,0)+1
  WHERE status='running'
    AND (
      (lease_expires_at IS NOT NULL AND lease_expires_at <= (extract(epoch from now())*1000)::bigint)
      OR (claimed_by IS NOT NULL AND claimed_by IN (SELECT owner FROM dead))
      OR (claimed_by IS NOT NULL AND NOT EXISTS (SELECT 1 FROM worker_heartbeats wh WHERE wh.owner=tasks.claimed_by))
    )
  RETURNING id
)
SELECT count(*)::bigint AS reclaimed FROM r;
