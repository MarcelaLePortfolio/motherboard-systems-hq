\pset pager off
\set ON_ERROR_STOP on

WITH rv AS (
  SELECT * FROM run_view
),
classified AS (
  SELECT
    rv.*,
    NULLIF(BTRIM(COALESCE(rv.actor, '')), '') AS actor_norm,
    NULLIF(BTRIM(COALESCE(rv.task_status, '')), '') AS task_status_norm,
    CASE
      WHEN rv.is_terminal IS TRUE THEN 'S_TERMINAL'
      WHEN rv.lease_fresh IS TRUE AND NULLIF(BTRIM(COALESCE(rv.actor, '')), '') IS NOT NULL THEN 'S_LEASE_FRESH_WITH_ACTOR'
      WHEN rv.lease_fresh IS TRUE AND NULLIF(BTRIM(COALESCE(rv.actor, '')), '') IS NULL THEN 'S_LEASE_FRESH_NO_ACTOR'
      WHEN (rv.lease_fresh IS FALSE OR rv.lease_fresh IS NULL) AND NULLIF(BTRIM(COALESCE(rv.actor, '')), '') IS NOT NULL THEN 'S_LEASE_STALE_WITH_ACTOR'
      WHEN (rv.lease_fresh IS FALSE OR rv.lease_fresh IS NULL) AND NULLIF(BTRIM(COALESCE(rv.actor, '')), '') IS NULL THEN 'S_NO_LEASE_NO_ACTOR'
      ELSE 'S_OTHER'
    END AS phase41_scenario
  FROM rv
)
SELECT
  run_id,
  task_id,
  task_status,
  is_terminal,
  actor,
  lease_fresh,
  lease_expires_at,
  lease_ttl_ms,
  last_heartbeat_ts,
  heartbeat_age_ms,
  last_event_kind,
  last_event_ts,
  terminal_event_kind,
  terminal_event_ts,
  phase41_scenario
FROM classified
ORDER BY run_id;
