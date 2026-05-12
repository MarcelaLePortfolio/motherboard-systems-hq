
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 FRESH SYSTEM RESET EXISTING TABLES ONLY ====="

DB_USER="$(docker compose exec -T postgres printenv POSTGRES_USER | tr -d '\r')"

DB_NAME="$(docker compose exec -T postgres printenv POSTGRES_DB | tr -d '\r')"

if [ -z "$DB_USER" ]; then DB_USER="postgres"; fi

if [ -z "$DB_NAME" ]; then DB_NAME="postgres"; fi

echo ""

echo "[1] Existing public tables"

docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -c "

SELECT tablename

FROM pg_tables

WHERE schemaname = 'public'

ORDER BY tablename;

"

echo ""

echo "[2] Counts before reset"

docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -c "

SELECT 'tasks' AS table_name, COUNT(*) FROM tasks

UNION ALL

SELECT 'task_events', COUNT(*) FROM task_events

ORDER BY table_name;

"

echo ""

echo "[3] Truncate existing history tables"

docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" <<'SQL'

TRUNCATE TABLE public.task_events RESTART IDENTITY CASCADE;

TRUNCATE TABLE public.tasks RESTART IDENTITY CASCADE;

SQL

echo ""

echo "[4] Counts after reset"

docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -c "

SELECT 'tasks' AS table_name, COUNT(*) FROM tasks

UNION ALL

SELECT 'task_events', COUNT(*) FROM task_events

ORDER BY table_name;

"

echo ""

echo "[5] Restart runtime"

docker compose up -d dashboard worker

sleep 8

docker compose ps

echo ""

echo "[6] API verification"

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks

echo ""

echo "[7] Commit reset helpers"

git add PHASE719_FRESH_SYSTEM_RESET.sh PHASE719_FRESH_SYSTEM_RESET_RETRY.sh PHASE719_FRESH_SYSTEM_RESET_SCHEMA_AWARE.sh PHASE719_FRESH_SYSTEM_RESET_EXISTING_TABLES_ONLY.sh

git commit -m "Phase 719: reset demo history using existing tables only" || true

git push origin dev

echo ""

echo "===== PHASE 719 FRESH SYSTEM RESET EXISTING TABLES ONLY COMPLETE ====="

