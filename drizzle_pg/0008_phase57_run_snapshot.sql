-- Phase 57 — Run Snapshot (immutable projection)
-- Purpose:
--   Materialize a deterministic, append-only snapshot per run_id
--   derived strictly from task_events (no UI inference, no mutation).

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

-- 2. Deterministic insert from canonical run_view
--    (assumes run_view already prefers ts/ts_ms over created_at)
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
  rv.status,
  rv.actor,
  rv.last_event_ts
FROM run_view rv
ON CONFLICT DO NOTHING;
