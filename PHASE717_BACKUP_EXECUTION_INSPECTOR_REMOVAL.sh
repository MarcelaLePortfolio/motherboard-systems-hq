
#!/bin/bash

set -e

echo "===== PHASE 717 BACKUP EXECUTION INSPECTOR REMOVAL ====="

echo ""

echo "[1] Verify clean runtime state"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Create stable tag"

git tag -f phase717-execution-inspector-removed

echo ""

echo "[3] Validate served dashboard state"

curl -sS http://localhost:3000/ | grep -o \

'Telemetry Console\|Recent Tasks\|Task History\|Execution Inspector\|id="recentTasks"' \

| sort | uniq -c

echo ""

echo "[4] Runtime status"

docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""

echo "[5] External archive backup"

./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh

echo ""

echo "[6] Push branch + tag"

git push origin dev

git push origin phase717-execution-inspector-removed --force

echo ""

echo "===== PHASE 717 EXECUTION INSPECTOR REMOVAL BACKUP COMPLETE ====="

