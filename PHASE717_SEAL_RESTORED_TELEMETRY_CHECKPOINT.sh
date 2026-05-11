
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 717 SEAL RESTORED TELEMETRY CHECKPOINT ====="

echo ""

echo "[1] Verify clean state"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Tag restored stable checkpoint"

git tag -f phase717-restored-telemetry-console

echo ""

echo "[3] Verify served dashboard anchors"

curl -sS http://localhost:3000/ | grep -o 'id="recentTasks"\|observational-workspace-card\|task-events-card\|mb-task-events-panel-anchor' | sort | uniq -c

echo ""

echo "[4] Runtime status"

docker compose ps --format "table {{.Name}}\t{{.Status}}"

echo ""

echo "[5] Push branch + tag"

git push origin dev

git push origin phase717-restored-telemetry-console --force

echo ""

echo "===== PHASE 717 RESTORE CHECKPOINT SEALED ====="

