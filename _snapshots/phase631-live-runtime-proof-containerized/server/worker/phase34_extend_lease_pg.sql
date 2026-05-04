-- Inputs:
--   $1 task_id (bigint)
--   $2 owner (text)
--   $3 lease_epoch (bigint)
--   $4 lease_ms (bigint)
UPDATE tasks
SET lease_expires_at = ((extract(epoch from now())*1000)::bigint + $4::bigint)
WHERE id = $1::bigint
  AND status = 'running'
  AND claimed_by = $2::text
  AND lease_epoch = $3::bigint
RETURNING id, lease_expires_at;
