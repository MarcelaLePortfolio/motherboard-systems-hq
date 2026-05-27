-- Verification-only helper: deterministically claim a specific task id.
-- Inputs: :task_id :owner :now_ms :lease_ms
UPDATE tasks
SET status='running',
    claimed_by=:'owner',
    claimed_at=:'now_ms'::bigint,
    lease_expires_at=(:'now_ms'::bigint + :'lease_ms'::bigint),
    lease_epoch=COALESCE(lease_epoch,0)+1
WHERE id = :'task_id'::bigint
  AND status = 'created'
RETURNING claimed_by;
