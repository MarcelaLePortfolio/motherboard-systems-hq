-- Phase 57 — Immutable projection: run_snapshots (append-only)
--
-- Purpose:
--   Deterministic, append-only snapshot rows derived strictly from task_events
--   via canonical run_view. No UI inference, no mutation.
--
-- Notes:
--   - run_view exposes task_status (not "status") and already performs tasks join.
--   - This phase adds an explicit refresh function so materialization can be invoked
--     deterministically (e.g., from a smoke harness or a future trigger/worker).

BEGIN;

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

-- Deterministic refresh: insert any missing snapshot rows for a specific run_id (or all runs if NULL).
CREATE OR REPLACE FUNCTION run_snapshots_refresh(p_run_id TEXT DEFAULT NULL)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
  inserted BIGINT;
BEGIN
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
    COALESCE(rv.task_status, 'unknown'),
    rv.actor,
    rv.last_event_ts
  FROM run_view rv
  WHERE (p_run_id IS NULL OR rv.run_id = p_run_id)
  ON CONFLICT DO NOTHING;

  GET DIAGNOSTICS inserted = ROW_COUNT;
  RETURN inserted;
END;
$$;

-- One-time idempotent backfill for existing run_view rows.
SELECT run_snapshots_refresh(NULL);

COMMIT;
