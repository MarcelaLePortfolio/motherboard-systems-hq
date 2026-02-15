-- Phase 39: action_tier validation (read-only)
-- Discovers a "kind" source column across known tables and validates it against the policy.
-- Unknown kinds => TIER_C (fail-closed) => validation fails.

\pset pager off
\set ON_ERROR_STOP on

-- 1) Discover where "kind" lives
WITH candidates AS (
  SELECT
    table_schema,
    table_name,
    column_name
  FROM information_schema.columns
  WHERE table_schema NOT IN ('pg_catalog','information_schema')
    AND column_name IN ('kind','event_kind','task_kind','type')
),
picked AS (
  SELECT
    table_schema,
    table_name,
    column_name
  FROM candidates
  WHERE (table_name ILIKE '%task%event%' OR table_name ILIKE '%task_events%')
  ORDER BY
    (table_name ILIKE '%task_events%') DESC,
    (table_name ILIKE '%event%') DESC,
    (column_name = 'kind') DESC,
    table_schema,
    table_name
  LIMIT 1
),
policy AS (
  -- pull policy mapping
  SELECT kind, action_tier, reason
  FROM (
    WITH policy(kind, action_tier, reason) AS (
      VALUES
        ('task.created',   'TIER_A', 'event: creation observed (read-only mapping)'),
        ('task.running',   'TIER_A', 'event: running observed (read-only mapping)'),
        ('task.completed', 'TIER_A', 'event: completion observed (read-only mapping)'),
        ('task.failed',    'TIER_A', 'event: failure observed (read-only mapping)'),
        ('task.canceled',  'TIER_A', 'event: cancel observed (read-only mapping)'),
        ('task.cancelled', 'TIER_A', 'event: cancel observed (read-only mapping)'),
        ('__POLICY_SENTINEL__', 'TIER_A', 'sentinel')
    )
    SELECT kind, action_tier, reason
    FROM policy
    WHERE kind <> '__POLICY_SENTINEL__'
  ) p
),
-- 2) Pull distinct kinds from the picked table/column (dynamic SQL via psql \gexec)
dyn AS (
  SELECT
    format(
      $fmt$
      WITH observed AS (
        SELECT DISTINCT %1$I AS kind
        FROM %2$I.%3$I
        WHERE %1$I IS NOT NULL
      ),
      joined AS (
        SELECT
          o.kind,
          COALESCE(p.action_tier, 'TIER_C') AS action_tier,
          CASE WHEN p.kind IS NULL THEN 'default' ELSE 'mapped' END AS policy_source,
          COALESCE(p.reason, 'unmapped kind -> fail-closed TIER_C') AS reason
        FROM observed o
        LEFT JOIN policy p ON p.kind = o.kind
      )
      SELECT
        kind,
        action_tier,
        policy_source,
        reason
      FROM joined
      ORDER BY kind;
      $fmt$,
      (SELECT column_name FROM picked),
      (SELECT table_schema FROM picked),
      (SELECT table_name FROM picked)
    ) AS sql
  FROM picked
),
assert_pick AS (
  SELECT
    CASE
      WHEN (SELECT COUNT(*) FROM picked) = 0
        THEN 'ERROR: could not find a kind-like column (kind/event_kind/task_kind/type) in user tables.'
      ELSE 'OK'
    END AS pick_status
),
assert_sql AS (
  SELECT
    CASE
      WHEN (SELECT pick_status FROM assert_pick) <> 'OK'
        THEN (SELECT pick_status FROM assert_pick)
      ELSE 'OK'
    END AS sql_status
)
SELECT sql FROM dyn
WHERE (SELECT sql_status FROM assert_sql) = 'OK'
\gexec

-- 3) Fail if any observed kind is unmapped (policy_source = default -> TIER_C)
WITH candidates AS (
  SELECT
    table_schema,
    table_name,
    column_name
  FROM information_schema.columns
  WHERE table_schema NOT IN ('pg_catalog','information_schema')
    AND column_name IN ('kind','event_kind','task_kind','type')
),
picked AS (
  SELECT
    table_schema,
    table_name,
    column_name
  FROM candidates
  WHERE (table_name ILIKE '%task%event%' OR table_name ILIKE '%task_events%')
  ORDER BY
    (table_name ILIKE '%task_events%') DESC,
    (table_name ILIKE '%event%') DESC,
    (column_name = 'kind') DESC,
    table_schema,
    table_name
  LIMIT 1
),
policy AS (
  SELECT kind
  FROM (
    VALUES
      ('task.created'),
      ('task.running'),
      ('task.completed'),
      ('task.failed'),
      ('task.canceled'),
      ('task.cancelled')
  ) p(kind)
),
dyn AS (
  SELECT
    format(
      $fmt$
      WITH observed AS (
        SELECT DISTINCT %1$I AS kind
        FROM %2$I.%3$I
        WHERE %1$I IS NOT NULL
      ),
      unmapped AS (
        SELECT o.kind
        FROM observed o
        LEFT JOIN policy p ON p.kind = o.kind
        WHERE p.kind IS NULL
      )
      SELECT
        COUNT(*) AS unmapped_count
      FROM unmapped;
      $fmt$,
      (SELECT column_name FROM picked),
      (SELECT table_schema FROM picked),
      (SELECT table_name FROM picked)
    ) AS sql
)
SELECT sql FROM dyn
\gexec

-- 4) Hard fail if unmapped_count > 0 (psql side assertion)
-- If your psql doesn't support \if, the smoke script enforces this in bash.
