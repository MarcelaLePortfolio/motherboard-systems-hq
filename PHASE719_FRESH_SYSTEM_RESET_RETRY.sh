
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 FRESH SYSTEM RESET RETRY ====="

echo ""

echo "[1] Inspect Postgres credentials"

docker compose exec -T postgres printenv | grep -E "POSTGRES_USER|POSTGRES_DB|POSTGRES_PASSWORD" || true

DB_USER="$(docker compose exec -T postgres printenv POSTGRES_USER | tr -d '\r')"

DB_NAME="$(docker compose exec -T postgres printenv POSTGRES_DB | tr -d '\r')"

if [ -z "$DB_USER" ]; then DB_USER="postgres"; fi

if [ -z "$DB_NAME" ]; then DB_NAME="postgres"; fi

echo "Using DB_USER=$DB_USER"

echo "Using DB_NAME=$DB_NAME"

echo ""

echo "[2] Snapshot current table counts"

docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -c "

SELECT 'tasks' AS table_name, COUNT(*) FROM tasks

UNION ALL

SELECT 'task_events', COUNT(*) FROM task_events

UNION ALL

SELECT 'runs', COUNT(*) FROM runs

UNION ALL

SELECT 'guidance', COUNT(*) FROM guidance

ORDER BY table_name;

" || true

echo ""

echo "[3] Clear demo/fake execution history"

docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" <<'SQL'

BEGIN;

TRUNCATE TABLE task_events RESTART IDENTITY CASCADE;

TRUNCATE TABLE runs RESTART IDENTITY CASCADE;

TRUNCATE TABLE guidance RESTART IDENTITY CASCADE;

TRUNCATE TABLE tasks RESTART IDENTITY CASCADE;

COMMIT;

SQL

echo ""

echo "[4] Verify empty task state"

docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -c "

SELECT 'tasks' AS table_name, COUNT(*) FROM tasks

UNION ALL

SELECT 'task_events', COUNT(*) FROM task_events

UNION ALL

SELECT 'runs', COUNT(*) FROM runs

UNION ALL

SELECT 'guidance', COUNT(*) FROM guidance

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

echo "[7] Commit reset helper"

git add PHASE719_FRESH_SYSTEM_RESET.sh PHASE719_FRESH_SYSTEM_RESET_RETRY.sh

git commit -m "Phase 719: reset demo execution history for fresh system state" || true

git push origin dev

echo ""

echo "===== PHASE 719 FRESH SYSTEM RESET RETRY COMPLETE ====="

