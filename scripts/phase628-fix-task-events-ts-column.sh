#!/usr/bin/env bash
set -euo pipefail

docker compose exec -T postgres psql -U postgres -d postgres << 'SQL'
ALTER TABLE task_events
ADD COLUMN IF NOT EXISTS ts BIGINT;

UPDATE task_events
SET ts = COALESCE(ts, (EXTRACT(EPOCH FROM created_at) * 1000)::BIGINT)
WHERE ts IS NULL;
SQL

curl -i --max-time 5 http://localhost:3000/events/task-events || true
