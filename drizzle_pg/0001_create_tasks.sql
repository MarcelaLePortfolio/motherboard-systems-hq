\set ON_ERROR_STOP on

-- Base tasks table for PG lane (required by run_view and dashboard queries)
-- Idempotent by design.

CREATE TABLE IF NOT EXISTS public.tasks (
  id                  BIGSERIAL PRIMARY KEY,
  task_id              TEXT NOT NULL UNIQUE,
  status               TEXT NOT NULL,
  kind                 TEXT,
  payload              JSONB,
  created_at           TIMESTAMPTZ DEFAULT now(),
  updated_at           TIMESTAMPTZ DEFAULT now(),

  -- Optional columns used by later phases / UI. Safe to exist early.
  title                TEXT,
  action_tier           TEXT,
  run_id               TEXT,

  claimed_by           TEXT,
  notes                TEXT,
  attempts             INTEGER DEFAULT 0,
  max_attempts         INTEGER,
  terminal_event_ts    BIGINT,
  terminal_event_kind  TEXT,

  -- Lease columns (phase34/35 will also ensure these exist; harmless duplication if they do)
  claimed_at           BIGINT,
  lease_expires_at     BIGINT,
  lease_epoch          INTEGER
);

-- Helpful indexes (safe if re-run)
CREATE INDEX IF NOT EXISTS idx_tasks_status ON public.tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_run_id ON public.tasks(run_id);
