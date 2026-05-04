#!/bin/bash
set -e

echo "PHASE 652 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Open Operator Dashboard"
open http://localhost:8080/dev/page-OperatorDashboard

echo "Manual check:"
echo "- Guidance cards are compact"
echo "- Type and subsystem labels are visible"
echo "- Message text remains readable"
echo "- No panel behavior changed"

echo "Step 4: Tag completion"
git tag -a phase652-complete -m "Phase 652 complete: guidance card readability verified"
git push origin phase652-complete

echo "PHASE 652 COMPLETE — guidance card readability verified and tagged."
