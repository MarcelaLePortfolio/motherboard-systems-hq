-- Phase 36.1 — Run-centric observability surface (read-only)
-- Canonical view: run_view keyed by run_id
--
-- NOTE: In the PG lane, task_events does NOT have a `cursor` column; ordering is via task_events.id (bigint/bigserial).
-- We expose last_event_id as the canonical "cursor-like" monotonic pointer.

CREATE OR REPLACE VIEW run_view AS
WITH
-- last event per (task_id, run_id)
last_event AS (
  SELECT DISTINCT ON (te.task_id, te.run_id)
    te.task_id,
    te.run_id,
    te.id     AS last_event_id,
    te.ts     AS last_event_ts,
    te.kind   AS last_event_kind,
    te.run_actor AS last_event_actor
  FROM task_events te
  WHERE te.run_id IS NOT NULL
  ORDER BY te.task_id, te.run_id, te.id DESC
),
-- latest heartbeat per (task_id, run_id)
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
-- terminal marker per (task_id, run_id) from events (if present)
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

  -- actor/owner (best-effort, run-scoped)
  le.last_event_actor AS actor,

  -- lease freshness (tasks table is the authoritative lease source)
  t.lease_expires_at,
  (t.lease_expires_at IS NOT NULL AND now() < t.lease_expires_at) AS lease_fresh,

  -- heartbeat freshness (run-scoped heartbeat event if present)
  lh.last_heartbeat_ts,
  CASE
    WHEN lh.last_heartbeat_ts IS NULL THEN NULL
    ELSE GREATEST(
      0,
      (extract(epoch from (now() - to_timestamp(lh.last_heartbeat_ts / 1000.0))) * 1000.0)
    )::bigint
  END AS heartbeat_age_ms,

  -- last event
  le.last_event_id,
  le.last_event_ts,
  le.last_event_kind,

  -- terminal state (prefer tasks.status; include terminal event if present)
  t.status AS task_status,
  (t.status IN ('completed','failed','canceled','cancelled')) AS is_terminal,
  te.terminal_event_kind,
  te.terminal_event_ts,
  te.terminal_event_id

FROM last_event le
JOIN tasks t
  ON t.id = le.task_id
LEFT JOIN last_heartbeat lh
  ON lh.task_id = le.task_id AND lh.run_id = le.run_id
LEFT JOIN terminal_event te
  ON te.task_id = le.task_id AND te.run_id = le.run_id
;
