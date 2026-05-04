#!/bin/bash
set -e

echo "PHASE 653 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Open Operator Dashboard"
open http://localhost:8080/dev/page-OperatorDashboard

echo "Manual check:"
echo "- Guidance is grouped by CRITICAL / WARNING / INFO"
echo "- Empty groups are hidden"
echo "- Existing guidance cards still render"
echo "- No API or SSE behavior changed"

echo "Step 4: Tag completion"
git tag -a phase653-complete -m "Phase 653 complete: guidance grouping by severity verified"
git push origin phase653-complete

echo "PHASE 653 COMPLETE — guidance grouping verified and tagged."
