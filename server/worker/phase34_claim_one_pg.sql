-- Inputs: $1=run_id, $2=owner, $3=lease_ms
-- Claim from status='created' (Phase33 contract)
WITH c AS (
  SELECT id, $1::text AS run_id
  FROM tasks
  WHERE status='created'
  ORDER BY id
  FOR UPDATE SKIP LOCKED
  LIMIT 1
)
UPDATE tasks t
SET status='running',
    run_id = c.run_id,
    claimed_by=$2,
    claimed_at=(extract(epoch from now())*1000)::bigint,
    lease_expires_at=((extract(epoch from now())*1000)::bigint + $3::bigint),
    lease_epoch=COALESCE(lease_epoch,0)+1
FROM c
WHERE t.id=c.id
RETURNING t.id, t.task_id, t.claimed_by, t.lease_expires_at, c.run_id;
