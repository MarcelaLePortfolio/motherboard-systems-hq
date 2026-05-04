\set ON_ERROR_STOP on

-- Phase 54 bootstrap: ensure fresh Postgres boot has the schema the dashboard expects.
-- This file is run by the official postgres image ONLY on first init (empty PGDATA).

-- Base tables / contracts first (safe + idempotent)
\i /migrations/drizzle_pg/0001_create_task_events.sql
\i /migrations/drizzle_pg/0006_phase32_1_task_events_contract.sql

-- Ensure tasks table exists (some repos create tasks outside drizzle_pg; if yours does too, this will be a no-op if already present elsewhere)
-- If tasks is created in another init script, fine. If not, we need it here; if this file doesn't exist in your repo, remove this line.
\i /migrations/drizzle_pg/0001_create_tasks.sql

-- Lease + heartbeat (required by run_view)
\i /migrations/drizzle_pg/0007_phase34_lease_heartbeat_reclaim.sql
\i /migrations/drizzle_pg/0007_phase35_lease_epoch.sql

-- Run observability surface
\i /migrations/drizzle_pg/0007_phase36_1_run_view.sql
\i /migrations/drizzle_pg/0007_phase36_2_run_view_contract.sql

-- Phase 57 snapshot table (optional but recommended for demo determinism)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_catalog.pg_class c
    JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relname = 'run_snapshots'
  ) THEN
    -- already there
    NULL;
  END IF;
END $$;

-- If the migration file exists in this repo, apply it (psql \i will fail if missing).
-- So we guard by relying on the file being mounted; if you don't have it, delete the next line.
\i /migrations/drizzle_pg/0008_phase57_run_snapshot.sql

