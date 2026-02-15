-- Phase 39: action_tier validation (read-only)
-- Produces:
--  1) A table of observed kinds with (action_tier, policy_source, reason)
--  2) A deterministic sentinel line: PHASE39_UNMAPPED_COUNT=<n>
--
-- Critical: any dynamic SQL executed via \gexec MUST be self-contained (no external CTE refs).

\pset pager off
\set ON_ERROR_STOP on

-- Discover a "kind" source column across known tables
WITH candidates AS (
  SELECT table_schema, table_name, column_name
  FROM information_schema.columns
  WHERE table_schema NOT IN ('pg_catalog','information_schema')
    AND column_name IN ('kind','event_kind','task_kind','type')
),
picked AS (
  SELECT table_schema, table_name, column_name
  FROM candidates
  WHERE (table_name ILIKE '%task%event%' OR table_name ILIKE '%task_events%')
  ORDER BY
    (table_name ILIKE '%task_events%') DESC,
    (table_name ILIKE '%event%') DESC,
    (column_name = 'kind') DESC,
    table_schema,
    table_name
  LIMIT 1
)
SELECT
  CASE
    WHEN (SELECT COUNT(*) FROM picked) = 0
      THEN 'ERROR: could not find a kind-like column (kind/event_kind/task_kind/type) in user tables.'
    ELSE 'OK'
  END AS pick_status
\gset

\if :'{?pick_status}' = 'ERROR: could not find a kind-like column (kind/event_kind/task_kind/type) in user tables.'
  \echo :pick_status
  \quit 2
\endif

-- 1) Emit observed kinds with tier mapping (self-contained SQL via \gexec)
WITH candidates AS (
  SELECT table_schema, table_name, column_name
  FROM information_schema.columns
  WHERE table_schema NOT IN ('pg_catalog','information_schema')
    AND column_name IN ('kind','event_kind','task_kind','type')
),
picked AS (
  SELECT table_schema, table_name, column_name
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
dyn AS (
  SELECT format(
    $fmt$
    WITH policy(kind, action_tier, reason) AS (
      VALUES
        ('task.created',   'TIER_A', 'event: creation observed (read-only mapping)'),
        ('task.running',   'TIER_A', 'event: running observed (read-only mapping)'),
        ('task.completed', 'TIER_A', 'event: completion observed (read-only mapping)'),
        ('task.failed',    'TIER_A', 'event: failure observed (read-only mapping)'),
        ('task.canceled',  'TIER_A', 'event: cancel observed (read-only mapping)'),
        ('task.cancelled', 'TIER_A', 'event: cancel observed (read-only mapping)')
    ),
    observed AS (
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
    SELECT kind, action_tier, policy_source, reason
    FROM joined
    ORDER BY kind;
    $fmt$,
    (SELECT column_name FROM picked),
    (SELECT table_schema FROM picked),
    (SELECT table_name FROM picked)
  ) AS sql
)
SELECT sql FROM dyn
\gexec

-- 2) Deterministic unmapped_count (self-contained SQL via \gexec, ends with sentinel line)
WITH candidates AS (
  SELECT table_schema, table_name, column_name
  FROM information_schema.columns
  WHERE table_schema NOT IN ('pg_catalog','information_schema')
    AND column_name IN ('kind','event_kind','task_kind','type')
),
picked AS (
  SELECT table_schema, table_name, column_name
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
dyn AS (
  SELECT format(
    $fmt$
    WITH policy(kind) AS (
      VALUES
        ('task.created'),
        ('task.running'),
        ('task.completed'),
        ('task.failed'),
        ('task.canceled'),
        ('task.cancelled')
    ),
    observed AS (
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
    SELECT 'PHASE39_UNMAPPED_COUNT=' || COUNT(*)::text AS phase39_unmapped_count
    FROM unmapped;
    $fmt$,
    (SELECT column_name FROM picked),
    (SELECT table_schema FROM picked),
    (SELECT table_name FROM picked)
  ) AS sql
)
SELECT sql FROM dyn
\gexec
