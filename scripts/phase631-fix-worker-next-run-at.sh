#!/usr/bin/env bash
set -euo pipefail

docker compose exec -T postgres psql -U postgres -d postgres << 'SQL'
ALTER TABLE tasks
ADD COLUMN IF NOT EXISTS next_run_at TIMESTAMPTZ;

UPDATE tasks
SET next_run_at = COALESCE(next_run_at, now())
WHERE status IN ('queued', 'pending');
SQL

docker compose restart worker

sleep 5

docker compose logs --tail=120 worker

curl -sS http://localhost:3000/api/tasks | jq .
