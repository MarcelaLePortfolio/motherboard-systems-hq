\pset pager off
\set ON_ERROR_STOP on

WITH rv AS (
  SELECT
    *
  FROM run_view
),
classified AS (
  SELECT
    rv.*,
    CASE
      WHEN rv.run_id IS NULL THEN NULL

      WHEN rv.status IN ('completed','failed','canceled','cancelled')
        THEN 'S_TERMINAL'

      WHEN (
        rv.status IN ('running','claimed')
        AND COALESCE(rv.claimed_by, '') <> ''
      ) THEN 'S_CLAIMED_RUNNING'

      WHEN (
        rv.status IN ('queued','created')
        AND COALESCE(rv.claimed_by, '') = ''
      ) THEN 'S_READY_UNCLAIMED'

      WHEN (
        rv.status IN ('queued','created')
        AND COALESCE(rv.claimed_by, '') <> ''
      ) THEN 'S_QUEUED_BUT_CLAIMED'

      WHEN (
        rv.status IN ('running','claimed')
        AND COALESCE(rv.claimed_by, '') = ''
      ) THEN 'S_RUNNING_BUT_UNCLAIMED'

      ELSE 'S_OTHER'
    END AS phase41_scenario
  FROM rv
)
SELECT
  run_id,
  task_id,
  status,
  attempts,
  max_attempts,
  claimed_by,
  phase41_scenario
FROM classified
ORDER BY run_id;
