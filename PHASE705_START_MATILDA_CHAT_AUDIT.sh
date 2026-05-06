#!/bin/bash
set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 705 — MATILDA CHAT REFINEMENT START"
echo "Goal: verify current chat surface before patching quality logic"
echo "────────────────────────────────"

echo ""
echo "1. Git state"
git status --short
git rev-parse --short HEAD
git branch --show-current

echo ""
echo "2. Container state"
docker compose ps

echo ""
echo "3. API health"
curl -sS http://localhost:3000/api/health || true

echo ""
echo "4. Advisory chat contract probe"
curl -sS -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Matilda, explain what you can and cannot do from this chat surface."}' | jq .

echo ""
echo "5. Search likely chat implementation files"
find . \
  -path "./node_modules" -prune -o \
  -path "./.next" -prune -o \
  -path "./snapshots" -prune -o \
  -type f \( \
    -name "route.ts" -o \
    -name "route.js" -o \
    -name "*.tsx" -o \
    -name "*.ts" -o \
    -name "*.mjs" \
  \) -print | grep -Ei "chat|matilda|server|api" | sort

echo ""
echo "6. Locate advisory contract strings"
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --exclude-dir=snapshots \
  --exclude-dir=.git \
  "advisory-deterministic\|execution:false\|systemCoupling\|/api/chat\|api/chat" . || true

echo ""
echo "PHASE 705 audit complete. Use output to identify the smallest safe Matilda chat quality patch."
