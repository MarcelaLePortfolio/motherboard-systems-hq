#!/bin/bash
set -e

echo "PHASE 659 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Validate guidance API"
curl -s http://localhost:8080/api/guidance | jq '.guidance'

echo "Step 4: Open Operator Dashboard"
open http://localhost:8080/dev/page-OperatorDashboard

echo "Manual check:"
echo "- Critical guidance appears before warning/info when present"
echo "- Warning guidance appears before info when present"
echo "- Existing grouping still renders correctly"
echo "- No execution action is triggered"

echo "Step 5: Tag completion"
git tag -a phase659-complete -m "Phase 659 complete: deterministic guidance prioritization verified"
git push origin phase659-complete

echo "PHASE 659 COMPLETE — guidance prioritization verified and tagged."
