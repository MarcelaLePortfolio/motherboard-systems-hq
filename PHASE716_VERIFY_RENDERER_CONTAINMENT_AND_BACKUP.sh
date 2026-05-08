
#!/bin/bash

set -u

echo "===== PHASE 716 VERIFY RENDERER CONTAINMENT + BACKUP ====="

echo ""

echo "[1] Confirm branch + latest commit"

git checkout dev

git status --short

git log --oneline -8

echo ""

echo "[2] Confirm renderer containment patch exists"

grep -n "data-phase716-contained-task\|advanced JSON\|max-height:220px" public/js/phase530_visible_panels_bridge.js || true

echo ""

echo "[3] Confirm no broad failed overflow CSS is present"

grep -Rni "phase716_zero_height_recent_tasks_fix.css\|phase716_execution_inspector_containment.css\|phase716-execution-inspector-overflow.css" public 2>/dev/null || true

echo ""

echo "[4] Rebuild authoritative containers"

docker compose up -d --build

echo ""

echo "[5] Confirm containers"

docker compose ps

echo ""

echo "[6] Confirm dashboard and APIs"

curl -sS -i "http://localhost:3000/" | head -30 || true

curl -sS -i "http://localhost:3000/api/tasks" | head -30 || true

curl -sS -i "http://localhost:3000/api/guidance" | head -25 || true

curl -sS -i "http://localhost:3000/execution-evidence.html" | head -25 || true

echo ""

echo "[7] External archive backup"

./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh

echo ""

echo "[8] Final status"

git status --short

git log --oneline -8

echo ""

echo "Manual browser check required:"

echo "1. Hard refresh http://localhost:3000/"

echo "2. Open Recent Tasks / Execution Inspector evidence details"

echo "3. Expand advanced JSON"

echo "4. Confirm JSON scrolls inside the task card and does not overlay following content"

echo ""

echo "===== PHASE 716 VERIFY RENDERER CONTAINMENT + BACKUP COMPLETE ====="

