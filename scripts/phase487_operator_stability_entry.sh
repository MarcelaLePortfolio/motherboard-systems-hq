#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — OPERATOR STABILITY ENTRY"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

echo
echo "== system posture check =="
git status --short

echo
echo "== running containers =="
docker compose ps

echo
echo "== endpoint probes =="
echo "-- dashboard (8080) --"
curl -s http://localhost:8080 | head -n 5 || true

echo
echo "-- api health (3001) --"
curl -s http://localhost:3001/health || true

echo
echo "-- tasks endpoint --"
curl -s http://localhost:3001/tasks || true

echo
echo "-- logs endpoint --"
curl -s http://localhost:3001/logs || true

echo
echo "────────────────────────────────"
echo "PHASE 487 — ENTRY COMPLETE"
echo "────────────────────────────────"
echo "Next:"
echo "1. Observe Operator Guidance behavior"
echo "2. Test Matilda response"
echo "3. Inspect logs readability"
echo "4. Identify UI-only fixes"
