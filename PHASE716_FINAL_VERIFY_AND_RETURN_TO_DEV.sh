
#!/bin/bash

set -u

echo "===== PHASE 716 FINAL VERIFY + RETURN TO DEV ====="

echo ""

echo "[1] Confirm sealed branch state"

git branch --show-current

git status --short

git log --oneline -5

echo ""

echo "[2] Confirm stable tag"

git tag --list | grep "phase716-static-execution-evidence-surface-stable" || true

git ls-remote --tags origin | grep "phase716-static-execution-evidence-surface-stable" || true

echo ""

echo "[3] Confirm external archive exists"

ls -lah "/Volumes/Rio Drive/Motherboard_Storage/snapshots" | tail -10 || true

echo ""

echo "[4] Return to dev"

git checkout dev

echo ""

echo "[5] Merge Phase 716 into dev"

git merge --ff-only phase716-execution-evidence-surfacing

echo ""

echo "[6] Push dev"

git push origin dev

echo ""

echo "[7] Final runtime proof"

curl -sS -i "http://localhost:3000/execution-evidence.html" | head -40 || true

curl -sS -i "http://localhost:3000/api/tasks" | head -60 || true

echo ""

echo "[8] Final status"

git status --short

git log --oneline -5

echo ""

echo "===== PHASE 716 MERGED TO DEV ====="

