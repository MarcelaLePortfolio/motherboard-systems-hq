\pset pager off
\set ON_ERROR_STOP on

WITH rv AS (
  SELECT * FROM run_view
),
norm AS (
  SELECT
    rv.*,
    NULLIF(BTRIM(COALESCE(rv.terminal_kind, '')), '') AS terminal_kind_norm,
    (rv.status IN ('completed','failed','canceled','cancelled')) AS status_is_terminal
  FROM rv
),
violations AS (
  SELECT
    'INV_001_one_row_per_run_id' AS invariant,
    run_id::text AS key,
    ('dup=' || COUNT(*)::text) AS detail
  FROM rv
  GROUP BY run_id
  HAVING COUNT(*) <> 1

  UNION ALL
  SELECT
    'INV_010_attempts_nonnegative' AS invariant,
    run_id::text AS key,
    ('attempts=' || COALESCE(attempts::text,'<null>')) AS detail
  FROM norm
  WHERE attempts IS NULL OR attempts < 0

  UNION ALL
  SELECT
    'INV_011_max_attempts_if_present_nonnegative' AS invariant,
    run_id::text AS key,
    ('max_attempts=' || COALESCE(max_attempts::text,'<null>')) AS detail
  FROM norm
  WHERE max_attempts IS NOT NULL AND max_attempts < 0

  UNION ALL
  SELECT
    'INV_012_attempts_le_max_attempts_when_present' AS invariant,
    run_id::text AS key,
    ('attempts=' || attempts::text || ' max_attempts=' || max_attempts::text) AS detail
  FROM norm
  WHERE max_attempts IS NOT NULL AND attempts IS NOT NULL AND attempts > max_attempts

  UNION ALL
  SELECT
    'INV_020_terminal_status_requires_terminal_kind' AS invariant,
    run_id::text AS key,
    ('status=' || status::text || ' terminal_kind=' || COALESCE(terminal_kind::text,'<null>')) AS detail
  FROM norm
  WHERE status_is_terminal AND terminal_kind_norm IS NULL

  UNION ALL
  SELECT
    'INV_021_terminal_kind_requires_terminal_at' AS invariant,
    run_id::text AS key,
    ('terminal_kind=' || terminal_kind_norm || ' terminal_at=' || COALESCE(terminal_at::text,'<null>')) AS detail
  FROM norm
  WHERE terminal_kind_norm IS NOT NULL AND terminal_at IS NULL

  UNION ALL
  SELECT
    'INV_022_terminal_at_requires_terminal_kind' AS invariant,
    run_id::text AS key,
    ('terminal_at=' || COALESCE(terminal_at::text,'<null>') || ' terminal_kind=' || COALESCE(terminal_kind::text,'<null>')) AS detail
  FROM norm
  WHERE terminal_at IS NOT NULL AND terminal_kind_norm IS NULL

  UNION ALL
  SELECT
    'INV_030_claimed_by_present_requires_claimed_or_running' AS invariant,
    run_id::text AS key,
    ('status=' || status::text || ' claimed_by=' || COALESCE(claimed_by::text,'<null>')) AS detail
  FROM norm
  WHERE NULLIF(BTRIM(COALESCE(claimed_by,'')),'') IS NOT NULL
    AND status NOT IN ('claimed','running','completed','failed','canceled','cancelled')

  UNION ALL
  SELECT
    'INV_031_running_or_claimed_requires_claimed_by' AS invariant,
    run_id::text AS key,
    ('status=' || status::text || ' claimed_by=' || COALESCE(claimed_by::text,'<null>')) AS detail
  FROM norm
  WHERE status IN ('claimed','running')
    AND NULLIF(BTRIM(COALESCE(claimed_by,'')),'') IS NULL

  UNION ALL
  SELECT
    'INV_040_terminal_rows_must_not_be_claimed_running' AS invariant,
    run_id::text AS key,
    ('status=' || status::text || ' claimed_by=' || COALESCE(claimed_by::text,'<null>')) AS detail
  FROM norm
  WHERE status_is_terminal
    AND NULLIF(BTRIM(COALESCE(claimed_by,'')),'') IS NOT NULL
)
SELECT * FROM violations
ORDER BY invariant, key;
