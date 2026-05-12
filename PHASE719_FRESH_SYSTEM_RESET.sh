
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 FRESH SYSTEM RESET ====="

echo ""

echo "[1] External archive backup before cleanup"

./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh

echo ""

echo "[2] Snapshot current database counts"

docker compose exec postgres psql -U motherboard -d motherboard_systems -c "

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

docker compose exec postgres psql -U motherboard -d motherboard_systems <<'SQL'

BEGIN;

TRUNCATE TABLE task_events RESTART IDENTITY CASCADE;

TRUNCATE TABLE runs RESTART IDENTITY CASCADE;

TRUNCATE TABLE guidance RESTART IDENTITY CASCADE;

TRUNCATE TABLE tasks RESTART IDENTITY CASCADE;

COMMIT;

SQL

echo ""

echo "[4] Rebuild authoritative runtime"

docker compose build dashboard worker

docker compose up -d dashboard worker

sleep 10

echo ""

echo "[5] Runtime verification"

docker compose ps

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks

echo ""

echo "[6] Commit fresh-system checkpoint"

git add -A

git commit -m "Phase 719: reset demo execution history for fresh system state" || true

git push origin dev

echo ""

echo "===== PHASE 719 FRESH SYSTEM RESET COMPLETE ====="

