
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="FRESH_POSTGRES_SCHEMA_BOOTSTRAP_INSPECTION.txt"

rm -f "$OUTPUT"

{

  echo "===== FRESH POSTGRES SCHEMA BOOTSTRAP INSPECTION ====="

  date

  echo

  echo "===== COMPOSE PS ====="

  docker compose ps

  echo

  echo "===== SQL / MIGRATION CANDIDATES ====="

  find docker-entrypoint-initdb.d drizzle drizzle_pg server sql -type f \( -name "*.sql" -o -name "*.mjs" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | sort | head -200

  echo

  echo "===== TASK TABLE REFERENCES ====="

  grep -Rni "create table.*tasks\|CREATE TABLE.*tasks\|alter table tasks\|task_events" docker-entrypoint-initdb.d drizzle drizzle_pg server sql 2>/dev/null | head -200 || true

  echo

  echo "===== POSTGRES TABLES BEFORE ====="

  docker compose exec -T postgres psql -U postgres -d postgres -c '\dt' || true

  echo

  echo "===== APPLY MINIMAL TASKS / TASK_EVENTS SCHEMA IF MISSING ====="

  docker compose exec -T postgres psql -U postgres -d postgres <<'SQL'

CREATE TABLE IF NOT EXISTS tasks (

  id SERIAL PRIMARY KEY,

  task_id TEXT UNIQUE,

  title TEXT,

  description TEXT,

  status TEXT DEFAULT 'queued',

  assignee TEXT,

  created_at TIMESTAMPTZ DEFAULT now(),

  updated_at TIMESTAMPTZ DEFAULT now(),

  completed_at TIMESTAMPTZ,

  failed_at TIMESTAMPTZ,

  error TEXT,

  metadata JSONB DEFAULT '{}'::jsonb

);

CREATE TABLE IF NOT EXISTS task_events (

  id SERIAL PRIMARY KEY,

  task_id TEXT,

  event_type TEXT,

  event_name TEXT,

  payload JSONB DEFAULT '{}'::jsonb,

  created_at TIMESTAMPTZ DEFAULT now()

);

ALTER TABLE tasks ADD COLUMN IF NOT EXISTS task_id TEXT;

ALTER TABLE tasks ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

ALTER TABLE task_events ADD COLUMN IF NOT EXISTS task_id TEXT;

ALTER TABLE task_events ADD COLUMN IF NOT EXISTS payload JSONB DEFAULT '{}'::jsonb;

SQL

  echo

  echo "===== POSTGRES TABLES AFTER ====="

  docker compose exec -T postgres psql -U postgres -d postgres -c '\dt'

  echo

  echo "===== RESTART DASHBOARD ====="

  docker compose up -d dashboard

  sleep 10

  docker compose ps

  echo

  echo "===== DASHBOARD LOGS AFTER RESTART ====="

  docker logs --tail 120 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== BASELINE HEALTH ====="

  curl -i http://localhost:8080/api/tasks/health || true

  echo

  echo "===== DASHBOARD ROOT ====="

  curl -I http://localhost:8080/ || true

  echo

  echo "===== WORKTREE ====="

  git status --short

} | tee "$OUTPUT"

git add inspect-and-bootstrap-fresh-postgres-schema.sh FRESH_POSTGRES_SCHEMA_BOOTSTRAP_INSPECTION.txt

git commit -m "Bootstrap fresh Postgres schema for runtime restore" || true

git push

