
#!/bin/bash

set -u

echo "===== PHASE 716 VERIFY OVERFLOW FIX ACTIVE ====="

echo ""

echo "[1] Confirm branch + clean git state"

git branch --show-current

git status --short

git log --oneline -5

echo ""

echo "[2] Confirm served dashboard includes overflow stylesheet"

curl -sS "http://localhost:3000/" | grep -n "phase716-execution-inspector-overflow.css" || true

echo ""

echo "[3] Confirm stylesheet serves containment rules"

curl -sS "http://localhost:3000/css/phase716-execution-inspector-overflow.css" | grep -n "max-height: 420px\|contain: layout paint\|overflow-wrap: anywhere" || true

echo ""

echo "[4] Confirm runtime APIs still healthy"

curl -sS -i "http://localhost:3000/api/tasks" | head -40 || true

curl -sS -i "http://localhost:3000/api/guidance" | head -30 || true

echo ""

echo "[5] Confirm containers"

docker compose ps

echo ""

echo "Manual browser check required:"

echo "1. Hard refresh http://localhost:3000/"

echo "2. Open Execution Inspector"

echo "3. Expand Advanced / JSON"

echo "4. Confirm JSON no longer overlays the next task card"

echo ""

echo "===== PHASE 716 OVERFLOW FIX ACTIVE VERIFICATION COMPLETE ====="

