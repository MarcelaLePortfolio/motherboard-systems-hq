\pset pager off
\set ON_ERROR_STOP on

WITH rv AS (
  SELECT * FROM run_view
),
norm AS (
  SELECT
    rv.*,
    NULLIF(BTRIM(COALESCE(rv.actor, '')), '') AS actor_norm,
    NULLIF(BTRIM(COALESCE(rv.task_status, '')), '') AS task_status_norm,
    NULLIF(BTRIM(COALESCE(rv.last_event_kind, '')), '') AS last_event_kind_norm,
    NULLIF(BTRIM(COALESCE(rv.terminal_event_kind, '')), '') AS terminal_event_kind_norm
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
    'INV_002_run_id_not_null' AS invariant,
    COALESCE(run_id::text,'<null>') AS key,
    'run_id is null' AS detail
  FROM norm
  WHERE run_id IS NULL

  UNION ALL
  SELECT
    'INV_003_task_id_not_null' AS invariant,
    run_id::text AS key,
    'task_id is null' AS detail
  FROM norm
  WHERE task_id IS NULL

  UNION ALL
  SELECT
    'INV_020_terminal_requires_terminal_event_kind' AS invariant,
    run_id::text AS key,
    ('is_terminal=' || COALESCE(is_terminal::text,'<null>') || ' terminal_event_kind=' || COALESCE(terminal_event_kind::text,'<null>')) AS detail
  FROM norm
  WHERE is_terminal IS TRUE AND terminal_event_kind_norm IS NULL

  UNION ALL
  SELECT
    'INV_021_terminal_requires_terminal_event_ts' AS invariant,
    run_id::text AS key,
    ('is_terminal=' || COALESCE(is_terminal::text,'<null>') || ' terminal_event_ts=' || COALESCE(terminal_event_ts::text,'<null>')) AS detail
  FROM norm
  WHERE is_terminal IS TRUE AND terminal_event_ts IS NULL

  UNION ALL
  SELECT
    'INV_022_terminal_requires_terminal_event_id' AS invariant,
    run_id::text AS key,
    ('is_terminal=' || COALESCE(is_terminal::text,'<null>') || ' terminal_event_id=' || COALESCE(terminal_event_id::text,'<null>')) AS detail
  FROM norm
  WHERE is_terminal IS TRUE AND terminal_event_id IS NULL

  UNION ALL
  SELECT
    'INV_023_nonterminal_must_not_expose_terminal_fields' AS invariant,
    run_id::text AS key,
    ('is_terminal=' || COALESCE(is_terminal::text,'<null>') || ' terminal_event_kind=' || COALESCE(terminal_event_kind::text,'<null>') || ' terminal_event_ts=' || COALESCE(terminal_event_ts::text,'<null>') || ' terminal_event_id=' || COALESCE(terminal_event_id::text,'<null>')) AS detail
  FROM norm
  WHERE (is_terminal IS FALSE OR is_terminal IS NULL)
    AND (terminal_event_kind_norm IS NOT NULL OR terminal_event_ts IS NOT NULL OR terminal_event_id IS NOT NULL)

  UNION ALL
  SELECT
    'INV_030_lease_fresh_requires_lease_expires_at' AS invariant,
    run_id::text AS key,
    ('lease_fresh=' || COALESCE(lease_fresh::text,'<null>') || ' lease_expires_at=' || COALESCE(lease_expires_at::text,'<null>')) AS detail
  FROM norm
  WHERE lease_fresh IS TRUE AND lease_expires_at IS NULL

  UNION ALL
  SELECT
    'INV_031_lease_ttl_ms_nonnegative_when_present' AS invariant,
    run_id::text AS key,
    ('lease_ttl_ms=' || COALESCE(lease_ttl_ms::text,'<null>')) AS detail
  FROM norm
  WHERE lease_ttl_ms IS NOT NULL AND lease_ttl_ms < 0

  UNION ALL
  SELECT
    'INV_032_heartbeat_age_ms_nonnegative_when_present' AS invariant,
    run_id::text AS key,
    ('heartbeat_age_ms=' || COALESCE(heartbeat_age_ms::text,'<null>')) AS detail
  FROM norm
  WHERE heartbeat_age_ms IS NOT NULL AND heartbeat_age_ms < 0

  UNION ALL
  SELECT
    'INV_040_last_event_id_implies_ts_and_kind' AS invariant,
    run_id::text AS key,
    ('last_event_id=' || COALESCE(last_event_id::text,'<null>') || ' last_event_ts=' || COALESCE(last_event_ts::text,'<null>') || ' last_event_kind=' || COALESCE(last_event_kind::text,'<null>')) AS detail
  FROM norm
  WHERE last_event_id IS NOT NULL AND (last_event_ts IS NULL OR last_event_kind_norm IS NULL)

  UNION ALL
  SELECT
    'INV_041_last_event_ts_or_kind_requires_id' AS invariant,
    run_id::text AS key,
    ('last_event_id=' || COALESCE(last_event_id::text,'<null>') || ' last_event_ts=' || COALESCE(last_event_ts::text,'<null>') || ' last_event_kind=' || COALESCE(last_event_kind::text,'<null>')) AS detail
  FROM norm
  WHERE last_event_id IS NULL AND (last_event_ts IS NOT NULL OR last_event_kind_norm IS NOT NULL)

  UNION ALL
  SELECT
    'INV_100_task_status_null_must_not_be_terminal' AS invariant,
    run_id::text AS key,
    ('task_status=<null> is_terminal=' || COALESCE(is_terminal::text,'<null>') || ' terminal_event_kind=' || COALESCE(terminal_event_kind::text,'<null>')) AS detail
  FROM norm
  WHERE task_status_norm IS NULL
    AND (
      is_terminal IS TRUE
      OR terminal_event_kind_norm IS NOT NULL
      OR terminal_event_ts IS NOT NULL
      OR terminal_event_id IS NOT NULL
    )

  UNION ALL
  SELECT
    'INV_101_task_status_null_must_not_have_fresh_lease' AS invariant,
    run_id::text AS key,
    ('task_status=<null> lease_fresh=' || COALESCE(lease_fresh::text,'<null>') || ' lease_expires_at=' || COALESCE(lease_expires_at::text,'<null>')) AS detail
  FROM norm
  WHERE task_status_norm IS NULL
    AND (
      lease_fresh IS TRUE
      OR lease_expires_at IS NOT NULL
      OR lease_ttl_ms IS NOT NULL
    )
)
SELECT * FROM violations
ORDER BY invariant, key;
