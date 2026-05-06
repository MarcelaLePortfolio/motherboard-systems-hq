#!/bin/bash
set -euo pipefail

echo "PHASE 705 — MINIMAL MATILDA AUDIT"

echo ""
echo "[1] HEAD"
git rev-parse --short HEAD

echo ""
echo "[2] Containers"
docker compose ps --format json | jq -r '.Name + " => " + .State'

echo ""
echo "[3] Chat contract"
curl -sS -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"What are your execution boundaries?"}' | jq '{mode,reply,meta}'

echo ""
echo "[4] Primary chat route candidates"
find . \
  -path "./node_modules" -prune -o \
  -path "./.next" -prune -o \
  -path "./snapshots" -prune -o \
  -type f \( -name "route.ts" -o -name "*.mjs" -o -name "*.ts" \) \
  | grep -Ei "/api/chat|chat|matilda" \
  | head -25

echo ""
echo "DONE"
