-- Phase 57 — Run Snapshot (immutable projection)
-- Purpose:
--   Materialize a deterministic, append-only snapshot per (run_id, task_id, last_event_id)
--   derived strictly from task_events (via run_view) + tasks for status.

-- 1. Snapshot table (append-only)
CREATE TABLE IF NOT EXISTS run_snapshots (
  id              BIGSERIAL PRIMARY KEY,
  run_id          TEXT NOT NULL,
  task_id         TEXT NOT NULL,
  last_event_id   BIGINT NOT NULL,
  last_event_ts   BIGINT NOT NULL,
  last_event_kind TEXT NOT NULL,
  status          TEXT NOT NULL,
  actor           TEXT,
  created_at_ms   BIGINT NOT NULL,

  UNIQUE (run_id, task_id, last_event_id)
);

-- 2. Deterministic insert from canonical run_view + tasks
--    - run_view provides last_event_* (ts precedence already handled upstream)
--    - tasks provides authoritative status
INSERT INTO run_snapshots (
  run_id,
  task_id,
  last_event_id,
  last_event_ts,
  last_event_kind,
  status,
  actor,
  created_at_ms
)
SELECT
  rv.run_id,
  rv.task_id,
  rv.last_event_id,
  rv.last_event_ts,
  rv.last_event_kind,
  t.status,
  COALESCE(rv.actor, t.actor),
  rv.last_event_ts
FROM run_view rv
JOIN tasks t
  ON t.task_id = rv.task_id
ON CONFLICT DO NOTHING;
