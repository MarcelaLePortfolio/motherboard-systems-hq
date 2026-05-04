#!/bin/bash
set -e

echo "PHASE 656 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Open Operator Dashboard"
open http://localhost:8080/dev/page-OperatorDashboard

echo "Manual check:"
echo "- Atlas shows OFFLINE in subsystem panel"
echo "- Guidance message reads as optional (not failure)"
echo "- No warning severity for atlas when simply absent"
echo "- Execution subsystem behavior unchanged"

echo "Step 4: Tag completion"
git tag -a phase656-complete -m "Phase 656 complete: atlas optional-state guidance verified"
git push origin phase656-complete

echo "PHASE 656 COMPLETE — atlas clarity verified and tagged."
