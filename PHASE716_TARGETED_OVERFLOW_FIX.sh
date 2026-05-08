
#!/bin/bash

set -u

echo "===== PHASE 716 TARGETED OVERFLOW FIX ====="

echo ""

echo "[1] Confirm source link + CSS"

grep -n "phase716_execution_inspector_containment.css" public/index.html public/dashboard.html || true

grep -n "recent-tasks-card\|tasks-widget\|max-height: 260px" public/css/phase716_execution_inspector_containment.css || true

echo ""

echo "[2] Rebuild authoritative containers"

docker compose up -d --build

echo ""

echo "[3] Confirm containers"

docker compose ps

echo ""

echo "[4] Confirm served root loads targeted containment CSS"

curl -sS "http://localhost:3000/" | grep -n "phase716_execution_inspector_containment.css" || true

echo ""

echo "[5] Confirm CSS asset serves"

curl -sS -i "http://localhost:3000/css/phase716_execution_inspector_containment.css" | head -40 || true

echo ""

echo "[6] Confirm runtime APIs still healthy"

curl -sS -i "http://localhost:3000/api/tasks" | head -40 || true

curl -sS -i "http://localhost:3000/api/guidance" | head -30 || true

echo ""

echo "[7] Final git status"

git status --short

echo ""

echo "===== PHASE 716 TARGETED OVERFLOW FIX COMPLETE ====="

