
#!/bin/bash

set -u

echo "===== PHASE 716 STATIC EXECUTION EVIDENCE PAGE VALIDATION ====="

echo ""

echo "[1] Branch + status"

git branch --show-current

git status --short

git log --oneline -6

echo ""

echo "[2] Source sanity check"

grep -n "Execution Evidence Surface\|Read-only operator proof surface\|/api/tasks\|trace_visibility" public/execution-evidence.html || true

echo ""

echo "[3] Rebuild authoritative containers"

docker compose up -d --build

echo ""

echo "[4] Confirm containers"

docker compose ps

echo ""

echo "[5] Probe static execution evidence page"

curl -sS -i "http://localhost:3000/execution-evidence.html" | head -80 || true

echo ""

echo "[6] Probe tasks API"

curl -sS -i "http://localhost:3000/api/tasks" | head -80 || true

echo ""

echo "[7] Confirm git state"

git status --short

echo ""

echo "===== PHASE 716 STATIC EXECUTION EVIDENCE PAGE VALIDATION COMPLETE ====="

