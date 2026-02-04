-- Phase 36.1 — Run-centric observability surface (read-only)
-- Canonical view: run_view keyed by run_id
--
-- PG lane schema notes:
-- - task_events has: id, kind, task_id(text), run_id(text), actor(text), ts(bigint)
-- - tasks has: id(bigint), task_id(text unique), run_id(text), actor(text), claimed_by(text), lease_expires_at(bigint)
-- - no task_events.cursor; ordering uses task_events.id
-- - lease_expires_at is bigint epoch ms (not timestamptz)

CREATE OR REPLACE VIEW run_view AS
WITH
last_event AS (
  SELECT DISTINCT ON (te.task_id, te.run_id)
    te.task_id,
    te.run_id,
    te.id   AS last_event_id,
    te.ts   AS last_event_ts,
    te.kind AS last_event_kind,
    te.actor AS last_event_actor
  FROM task_events te
  WHERE te.run_id IS NOT NULL
  ORDER BY te.task_id, te.run_id, te.id DESC
),
last_heartbeat AS (
  SELECT
    te.task_id,
    te.run_id,
    MAX(te.ts) AS last_heartbeat_ts
  FROM task_events te
  WHERE te.run_id IS NOT NULL
    AND te.kind = 'heartbeat'
  GROUP BY te.task_id, te.run_id
),
terminal_event AS (
  SELECT DISTINCT ON (te.task_id, te.run_id)
    te.task_id,
    te.run_id,
    te.kind AS terminal_event_kind,
    te.ts   AS terminal_event_ts,
    te.id   AS terminal_event_id
  FROM task_events te
  WHERE te.run_id IS NOT NULL
    AND te.kind IN ('completed','failed','canceled','cancelled')
  ORDER BY te.task_id, te.run_id, te.id DESC
)
SELECT
  le.run_id,
  le.task_id,

  -- actor/owner: prefer latest event.actor; fall back to tasks.claimed_by / tasks.actor
  COALESCE(NULLIF(le.last_event_actor,''), NULLIF(t.claimed_by,''), NULLIF(t.actor,'')) AS actor,

  -- lease (epoch ms)
  t.lease_expires_at,
  CASE
    WHEN t.lease_expires_at IS NULL THEN NULL
    ELSE (t.lease_expires_at > (extract(epoch from now()) * 1000.0))::boolean
  END AS lease_fresh,
  CASE
    WHEN t.lease_expires_at IS NULL THEN NULL
    ELSE GREATEST(0, (t.lease_expires_at - (extract(epoch from now()) * 1000.0)))::bigint
  END AS lease_ttl_ms,

  -- heartbeat freshness (epoch ms)
  lh.last_heartbeat_ts,
  CASE
    WHEN lh.last_heartbeat_ts IS NULL THEN NULL
    ELSE GREATEST(0, ((extract(epoch from now()) * 1000.0) - lh.last_heartbeat_ts))::bigint
  END AS heartbeat_age_ms,

  -- last event
  le.last_event_id,
  le.last_event_ts,
  le.last_event_kind,

  -- terminal state
  t.status AS task_status,
  (t.status IN ('completed','failed','canceled','cancelled')) AS is_terminal,
  te.terminal_event_kind,
  te.terminal_event_ts,
  te.terminal_event_id

FROM last_event le
LEFT JOIN tasks t
  ON t.task_id = le.task_id
LEFT JOIN last_heartbeat lh
  ON lh.task_id = le.task_id AND lh.run_id = le.run_id
LEFT JOIN terminal_event te
  ON te.task_id = le.task_id AND te.run_id = le.run_id
;
