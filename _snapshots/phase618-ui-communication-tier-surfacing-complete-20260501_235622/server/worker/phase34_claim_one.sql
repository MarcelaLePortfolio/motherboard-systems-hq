-- Inputs: :owner :now_ms :lease_ms
-- Claim policy (align with Phase33): claim from status='created'

WITH c AS (
  SELECT id
  FROM tasks
  WHERE status='created'
  ORDER BY id
  FOR UPDATE SKIP LOCKED
  LIMIT 1
)
UPDATE tasks t
SET status='running',
    claimed_by=:'owner',
    claimed_at=:'now_ms'::bigint,
    lease_expires_at=(:'now_ms'::bigint + :'lease_ms'::bigint),
    lease_epoch=COALESCE(lease_epoch,0)+1
FROM c
WHERE t.id=c.id
RETURNING t.claimed_by;
