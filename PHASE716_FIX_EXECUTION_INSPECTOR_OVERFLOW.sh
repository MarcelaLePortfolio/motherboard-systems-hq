
#!/bin/bash

set -u

echo "===== PHASE 716 EXECUTION INSPECTOR OVERFLOW FIX ====="

echo ""

echo "[1] Branch + status"

git branch --show-current

git status --short

echo ""

echo "[2] Confirm CSS injection"

grep -n "phase716-execution-inspector-overflow.css" public/dashboard.html

grep -n "Execution Inspector overflow containment\|max-height: 420px\|contain: layout paint" public/css/phase716-execution-inspector-overflow.css

echo ""

echo "[3] Rebuild authoritative containers"

docker compose up -d --build

echo ""

echo "[4] Confirm containers"

docker compose ps

echo ""

echo "[5] Verify dashboard serves overflow CSS link"

curl -sS "http://localhost:3000/" | grep -n "phase716-execution-inspector-overflow.css" || true

echo ""

echo "[6] Verify CSS asset serves"

curl -sS -i "http://localhost:3000/css/phase716-execution-inspector-overflow.css" | head -60 || true

echo ""

echo "[7] Final status"

git status --short

echo ""

echo "===== PHASE 716 EXECUTION INSPECTOR OVERFLOW FIX COMPLETE ====="

