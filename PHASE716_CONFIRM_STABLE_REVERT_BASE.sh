
#!/bin/bash

set -u

echo "===== PHASE 716 CONFIRM STABLE REVERT BASE ====="

echo ""

echo "[1] Confirm clean dev"

git checkout dev

git status --short

git log --oneline -10

echo ""

echo "[2] Confirm backup snapshot exists"

ls -lah "/Volumes/Rio Drive/Motherboard_Storage/snapshots" | tail -8 || true

echo ""

echo "[3] Confirm preserved Phase 716 win"

curl -sS -i "http://localhost:3000/execution-evidence.html" | head -40 || true

echo ""

echo "[4] Confirm runtime still healthy"

docker compose ps

curl -sS -i "http://localhost:3000/api/tasks" | head -30 || true

curl -sS -i "http://localhost:3000/api/guidance" | head -25 || true

echo ""

echo "[5] Confirm failed overflow/layout CSS remains absent"

grep -Rni "phase716_zero_height_recent_tasks_fix.css\|phase716_execution_inspector_containment.css\|phase716-execution-inspector-overflow.css" public 2>/dev/null || true

echo ""

echo "PHASE 716 STATUS:"

echo "- Stable reverted base preserved."

echo "- External archive captured source-3e869030."

echo "- Static execution evidence surface preserved."

echo "- Overflow remains unresolved and should NOT be fixed with broad CSS height/overflow patches."

echo "- Next attempt should target the actual renderer/DOM structure narrowly, not global telemetry layout."

echo ""

echo "===== PHASE 716 CONFIRM STABLE REVERT BASE COMPLETE ====="

