-- Phase 39: Claim-one with Tier enforcement gate (pg-client safe; 3 params)
--
-- Behavior:
--  - If a queued Tier B/C task exists, return it as REFUSE (no mutation).
--  - Otherwise, claim a queued Tier A (or NULL) task via UPDATE ... RETURNING.
--
-- Params:
--  $1 = run_id (text)
--  $2 = claimed_by / owner (text)
--  $3 = lease_ms (bigint)  -- referenced for arity compatibility (not used in Phase39 semantics)
--
-- Output: single row, gate_action = 'REFUSE' | 'CLAIM'

WITH params AS (
  SELECT
    $1::text   AS run_id,
    $2::text   AS claimed_by,
    $3::bigint AS lease_ms
),
disallowed AS (
  SELECT t.id, t.task_id, t.title, t.action_tier
  FROM tasks t
  WHERE t.status = 'queued'
    AND t.action_tier IN ('B','C')
  ORDER BY t.id
  FOR UPDATE SKIP LOCKED
  LIMIT 1
),
allowed_pick AS (
  SELECT t.id
  FROM tasks t
  WHERE t.status = 'queued'
    AND (t.action_tier IS NULL OR t.action_tier = 'A')
    AND NOT EXISTS (SELECT 1 FROM disallowed)
  ORDER BY t.id
  FOR UPDATE SKIP LOCKED
  LIMIT 1
),
claimed AS (
  UPDATE tasks t
  SET status     = 'delegated',
      run_id     = (SELECT run_id FROM params),
      claimed_by = (SELECT claimed_by FROM params),
      claimed_at = (floor(extract(epoch from clock_timestamp())*1000))::bigint
  WHERE t.id = (SELECT id FROM allowed_pick)
  RETURNING t.id, t.task_id, t.title, t.action_tier
)
SELECT
  'REFUSE'::text AS gate_action,
  d.id,
  d.task_id,
  d.title,
  d.action_tier
FROM disallowed d
UNION ALL
SELECT
  'CLAIM'::text AS gate_action,
  c.id,
  c.task_id,
  c.title,
  c.action_tier
FROM claimed c;
