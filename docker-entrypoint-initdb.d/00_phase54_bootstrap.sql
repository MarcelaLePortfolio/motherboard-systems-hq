\set ON_ERROR_STOP on

-- Phase 54 bootstrap: ensure fresh Postgres boot has the schema the dashboard expects.
-- This file is run by the official postgres image ONLY on first init (empty PGDATA).

BEGIN;

CREATE TABLE IF NOT EXISTS public.task_events (
  id BIGSERIAL PRIMARY KEY,
  task_id TEXT,
  kind TEXT NOT NULL,
  actor TEXT,
  payload JSONB DEFAULT '{}'::jsonb,
  run_id TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  ts BIGINT
);

CREATE INDEX IF NOT EXISTS task_events_task_id_idx ON public.task_events(task_id);
CREATE INDEX IF NOT EXISTS task_events_kind_idx ON public.task_events(kind);

CREATE TABLE IF NOT EXISTS public.tasks (
  id BIGSERIAL PRIMARY KEY,
  task_id TEXT UNIQUE,
  status TEXT DEFAULT 'queued',
  kind TEXT,
  payload JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  title TEXT,
  action_tier TEXT,
  run_id TEXT,
  claimed_by TEXT,
  notes TEXT,
  attempts INTEGER NOT NULL DEFAULT 0,
  max_attempts INTEGER DEFAULT 3,
  next_run_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS tasks_task_id_idx ON public.tasks(task_id);

ALTER TABLE public.tasks
ADD COLUMN IF NOT EXISTS next_run_at TIMESTAMPTZ;

ALTER TABLE public.tasks
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;

COMMIT;
