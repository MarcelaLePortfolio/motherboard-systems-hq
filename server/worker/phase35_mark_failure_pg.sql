-- Phase 35 guarded mark_failure (pg positional)
-- Inputs:
--   $1 task_id (bigint)
--   $2 owner (text)
--   $3 lease_epoch (bigint)
--   $4 err (text)   -- currently unused by SQL; preserved for call-site parity

UPDATE tasks
SET status = 'failed',
    lease_expires_at = NULL
WHERE id = $1::bigint
  AND status = 'running'
  AND claimed_by = $2
  AND lease_epoch = $3::bigint
RETURNING id;
