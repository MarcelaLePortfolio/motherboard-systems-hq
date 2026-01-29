-- Phase 34: lease/heartbeat/reclaim (minimal, idempotent-ish)

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tasks' AND column_name='claimed_by') THEN
    ALTER TABLE tasks ADD COLUMN claimed_by TEXT NULL;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tasks' AND column_name='claimed_at') THEN
    ALTER TABLE tasks ADD COLUMN claimed_at BIGINT NULL;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tasks' AND column_name='lease_expires_at') THEN
    ALTER TABLE tasks ADD COLUMN lease_expires_at BIGINT NULL;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tasks' AND column_name='lease_epoch') THEN
    ALTER TABLE tasks ADD COLUMN lease_epoch INT NOT NULL DEFAULT 0;
  END IF;
EXCEPTION WHEN others THEN
  RAISE NOTICE 'phase34 migration: %', SQLERRM;
END $$;

CREATE TABLE IF NOT EXISTS worker_heartbeats (
  owner TEXT PRIMARY KEY,
  last_seen_at BIGINT NOT NULL
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE schemaname='public' AND tablename='tasks' AND indexname='tasks_lease_expires_at_idx'
  ) THEN
    CREATE INDEX tasks_lease_expires_at_idx ON tasks(lease_expires_at);
  END IF;
EXCEPTION WHEN others THEN
  RAISE NOTICE 'phase34 index: %', SQLERRM;
END $$;
