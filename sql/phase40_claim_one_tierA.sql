
-- Phase 40 — SQL-first Tier A claim gate (canonical claim SQL)

--

-- Contract:

-- - Only Tier A (action_tier='A') tasks are claimable via this path.

-- - Planning-only governed_planning records are not claimable.

-- - Deterministic ordering is explicit.

-- - Concurrency-safe selection (FOR UPDATE SKIP LOCKED).

-- - No JS-derived state.

--

-- Inputs:

--   $1 = run_id

--   $2 = claimed_by

WITH candidate AS (

  SELECT id

  FROM tasks

  WHERE status = 'queued'

    AND COALESCE(kind, '') <> 'governed_planning'

    AND COALESCE(action_tier, 'A') = 'A'

    AND attempts < COALESCE(max_attempts, 2147483647)

  ORDER BY id ASC

  FOR UPDATE SKIP LOCKED

  LIMIT 1

)

UPDATE tasks t

SET status = 'running',

    claimed_by = $2,

    run_id = COALESCE(t.run_id, $1)

FROM candidate c

WHERE t.id = c.id

RETURNING

  t.id,

  t.task_id,

  t.title,

  t.status,

  t.action_tier,

  t.attempts,

  t.max_attempts,

  t.claimed_by,

  t.run_id;

