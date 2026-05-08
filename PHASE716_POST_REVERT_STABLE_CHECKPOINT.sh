
#!/bin/bash

set -u

echo "===== PHASE 716 POST-REVERT STABLE CHECKPOINT ====="

rm -f PHASE716_REVERT_ZERO_HEIGHT_LAYOUT_BREAK.sh

echo ""

echo "[1] Confirm dev state"

git checkout dev

git status --short

git log --oneline -8

echo ""

echo "[2] Confirm failed zero-height CSS removed"

grep -Rni "phase716_zero_height_recent_tasks_fix.css" public 2>/dev/null || true

echo ""

echo "[3] Confirm Phase 716 evidence surface preserved"

test -f public/execution-evidence.html && echo "execution evidence surface preserved"

grep -n "Execution Evidence Surface" public/execution-evidence.html || true

echo ""

echo "[4] Confirm runtime"

docker compose ps

echo ""

echo "[5] Confirm dashboard + APIs"

curl -sS -i "http://localhost:3000/" | head -30 || true

curl -sS -i "http://localhost:3000/api/tasks" | head -25 || true

curl -sS -i "http://localhost:3000/api/guidance" | head -25 || true

echo ""

echo "[6] External archive backup at reverted stable point"

./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh

echo ""

echo "[7] Final status"

git status --short

git log --oneline -8

echo ""

echo "===== PHASE 716 POST-REVERT STABLE CHECKPOINT COMPLETE ====="

