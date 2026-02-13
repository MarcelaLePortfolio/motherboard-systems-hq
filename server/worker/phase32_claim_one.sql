/*
Phase 32 — claim one task (no-lease variant)
Params:
  $1 = run_id (text)
  $2 = owner  (text)
*/
WITH pick AS (
  SELECT id
  FROM tasks
  WHERE status IN ('queued','created')
  ORDER BY id
  FOR UPDATE SKIP LOCKED
  LIMIT 1
),
upd AS (
  UPDATE tasks t
  SET
    status     = 'running',
    run_id     = $1,
    claimed_by = $2,
    -- keep task_id stable; if NULL, backfill from id as text
    task_id    = COALESCE(t.task_id, t.id::text)
  FROM pick
  WHERE t.id = pick.id
  RETURNING t.*
)
SELECT * FROM upd;
