BEGIN;

-- Phase 54 CI/bootstrap: ensure baseline tables exist AND align schema with app expectations.
-- Idempotent by construction.

-- tasks: ensure table exists (baseline), then add expected columns/constraints
CREATE TABLE IF NOT EXISTS public.tasks (
  id bigserial PRIMARY KEY,
  task_id text,
  status text,
  kind text,
  payload jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  title text,
  action_tier text,

  -- app/worker expectations (may be unused in earlier phases but must exist)
  run_id text,
  claimed_by text,
  notes text,
  attempts integer NOT NULL DEFAULT 0,
  max_attempts integer
);

CREATE INDEX IF NOT EXISTS tasks_task_id_idx ON public.tasks(task_id);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.tasks'::regclass
      AND contype = 'u'
      AND conname = 'tasks_task_id_key'
  ) THEN
    ALTER TABLE public.tasks
      ADD CONSTRAINT tasks_task_id_key UNIQUE (task_id);
  END IF;
END
$$;
-- task_events: ensure table exists, ensure ts is bigint epoch-ms
CREATE TABLE IF NOT EXISTS public.task_events (
  id bigserial PRIMARY KEY,
  task_id text,
  kind text,
  actor text,
  payload jsonb,
  created_at timestamptz DEFAULT now(),
  run_id text
);

CREATE INDEX IF NOT EXISTS task_events_task_id_idx ON public.task_events(task_id);
CREATE INDEX IF NOT EXISTS task_events_created_at_idx ON public.task_events(created_at);

-- Ensure ts exists and is bigint (epoch-ms).
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema='public'
      AND table_name='task_events'
      AND column_name='ts'
      AND data_type <> 'bigint'
  ) THEN
    EXECUTE 'ALTER TABLE public.task_events DROP COLUMN ts';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema='public'
      AND table_name='task_events'
      AND column_name='ts'
  ) THEN
    EXECUTE 'ALTER TABLE public.task_events ADD COLUMN ts bigint NOT NULL DEFAULT (extract(epoch from now()) * 1000)::bigint';
  END IF;
END
$$;

COMMIT;
