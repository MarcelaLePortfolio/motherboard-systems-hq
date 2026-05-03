#!/usr/bin/env bash
set -euo pipefail

docker compose exec -T postgres psql -U postgres -d postgres << 'SQL'
ALTER TABLE task_events
ADD COLUMN IF NOT EXISTS actor TEXT;
SQL

curl -i --max-time 5 http://localhost:3000/events/task-events || true
