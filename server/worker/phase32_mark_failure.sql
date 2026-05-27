/*
Phase 32 — mark failure (no retry scheduling here; keep minimal + deterministic)
Params:
  $1 = task_id (text)
  $2 = run_id  (text|null)
  $3 = actor   (text|null)
*/
UPDATE tasks
SET
  status       = 'failed',
  completed_at = NOW(),
  run_id       = COALESCE($2, run_id),
  claimed_by   = COALESCE(NULLIF(claimed_by,''), $3)
WHERE task_id = $1
RETURNING *;
