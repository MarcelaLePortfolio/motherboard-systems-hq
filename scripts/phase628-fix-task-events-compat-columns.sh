#!/usr/bin/env bash
set -euo pipefail

docker compose exec -T postgres psql -U postgres -d postgres << 'SQL'
ALTER TABLE task_events
ADD COLUMN IF NOT EXISTS run_id TEXT,
ADD COLUMN IF NOT EXISTS status TEXT,
ADD COLUMN IF NOT EXISTS cursor BIGINT;

UPDATE task_events
SET cursor = COALESCE(cursor, ts, id::bigint)
WHERE cursor IS NULL;
SQL

curl -i --max-time 5 http://localhost:3000/events/task-events || true
