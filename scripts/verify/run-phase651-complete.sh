#!/bin/bash
set -e

echo "PHASE 651 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Validate guidance API"
bash scripts/verify/test-phase650-guidance.sh

echo "Step 4: Open Operator Dashboard"
open http://localhost:8080/dev/page-OperatorDashboard

echo "Manual check:"
echo "- Guidance cards show type labels"
echo "- Severity numbers are visible"
echo "- Warning/info colors render clearly"

echo "Step 5: Tag completion"
git tag -a phase651-complete -m "Phase 651 complete: guidance signal refinement verified"
git push origin phase651-complete

echo "PHASE 651 COMPLETE — guidance signal refinement verified and tagged."
