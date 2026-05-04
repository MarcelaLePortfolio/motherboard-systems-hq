#!/usr/bin/env bash
set -euo pipefail

TASK_ID="t_1db588b7-e427-4203-8903-06fb7725a573"

docker compose exec -T postgres psql -U postgres -d postgres << SQL
ALTER TABLE tasks
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;

UPDATE tasks
SET status = 'queued',
    claimed_by = NULL,
    next_run_at = now(),
    updated_at = now()
WHERE task_id = '${TASK_ID}';
SQL

docker compose restart worker

sleep 6

docker compose logs --tail=140 worker

curl -sS http://localhost:3000/api/tasks | jq .
