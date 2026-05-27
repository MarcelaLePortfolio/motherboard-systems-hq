\pset pager off

-- Phase 40 — Acceptance checks (scoped)
-- Prove: Tier B/C remain queued after canonical claim SQL runs.

WITH scoped AS (
  SELECT id, task_id, status, action_tier, claimed_by, run_id
  FROM tasks
  WHERE task_id LIKE 'smoke.phase40.tiergate.%'
)
SELECT
  task_id,
  status,
  action_tier,
  claimed_by,
  run_id
FROM scoped
ORDER BY task_id;

-- Hard gate: no non-A tasks may be running
WITH bad AS (
  SELECT *
  FROM tasks
  WHERE task_id LIKE 'smoke.phase40.tiergate.%'
    AND COALESCE(action_tier,'A') <> 'A'
    AND status = 'running'
)
SELECT
  CASE WHEN EXISTS (SELECT 1 FROM bad)
       THEN 'FAIL: non-A task is running'
       ELSE 'OK: no non-A tasks running'
  END AS tier_gate_result;

-- Hard gate: exactly one A task should be running (since we claim once)
WITH a_running AS (
  SELECT count(*) AS n
  FROM tasks
  WHERE task_id LIKE 'smoke.phase40.tiergate.%'
    AND COALESCE(action_tier,'A') = 'A'
    AND status = 'running'
)
SELECT
  CASE WHEN (SELECT n FROM a_running) = 1
       THEN 'OK: exactly one A task running'
       ELSE 'FAIL: expected exactly one A task running'
  END AS tierA_running_count_result,
  (SELECT n FROM a_running) AS tierA_running_count;
