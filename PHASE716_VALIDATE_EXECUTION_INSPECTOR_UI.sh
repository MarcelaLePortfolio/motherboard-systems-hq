
#!/bin/bash

set -u

echo "===== PHASE 716 EXECUTION INSPECTOR UI VALIDATION ====="

echo ""

echo "[1] Branch + status"

git branch --show-current

git status --short

git log --oneline -5

echo ""

echo "[2] Type/source sanity check"

grep -n "read-only execution evidence\|View execution evidence\|View system trace payload\|EvidenceRow" app/components/ExecutionInspector.tsx || true

echo ""

echo "[3] Rebuild authoritative containers"

docker compose up -d --build

echo ""

echo "[4] Confirm containers after rebuild"

docker compose ps

echo ""

echo "[5] Probe guidance API"

curl -sS -i "http://localhost:3000/api/guidance" | head -40 || true

echo ""

echo "[6] Probe tasks API for surfaced evidence fields"

curl -sS -i "http://localhost:3000/api/tasks" | head -80 || true

echo ""

echo "[7] Probe dev inspector page"

curl -sS -i "http://localhost:3000/dev/page-ExecutionInspectorTest" | head -40 || true

echo ""

echo "[8] Confirm git state"

git status --short

echo ""

echo "===== PHASE 716 EXECUTION INSPECTOR UI VALIDATION COMPLETE ====="

