
#!/bin/bash

set -e

echo "===== PHASE 717 SEAL POST INSPECTOR REMOVAL STATE ====="

echo ""

echo "[1] Verify state"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Create authoritative checkpoint tag"

git tag -f phase717-stable-telemetry-console

echo ""

echo "[3] Validate served dashboard"

curl -sS http://localhost:3000/ | grep -o 'Telemetry Console\|Recent Tasks\|Task History\|Execution Inspector\|id="recentTasks"' | sort | uniq -c || true

echo ""

echo "[4] Runtime status"

docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""

echo "[5] Push branch + tag"

git push origin dev

git push origin phase717-stable-telemetry-console --force

echo ""

echo "===== PHASE 717 STABLE TELEMETRY CONSOLE SEALED ====="

