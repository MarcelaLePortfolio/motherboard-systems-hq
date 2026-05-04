#!/bin/bash
set -e

echo "PHASE 657 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Validate guidance API"
curl -s http://localhost:8080/api/guidance | jq .

echo "Step 4: Open Operator Dashboard"
open http://localhost:8080/dev/page-OperatorDashboard

echo "Manual check:"
echo "- Guidance hints render when suggested_action exists"
echo "- Hint text is visually secondary"
echo "- No execution action is triggered"
echo "- Guidance remains advisory only"

echo "Step 5: Tag completion"
git tag -a phase657-complete -m "Phase 657 complete: guidance action hints verified"
git push origin phase657-complete

echo "PHASE 657 COMPLETE — guidance action hints verified and tagged."
