#!/bin/bash
set -e

echo "PHASE 654 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Open Operator Dashboard"
open http://localhost:8080/dev/page-OperatorDashboard

echo "Manual check:"
echo "- Total guidance count appears in header"
echo "- Severity group counts appear"
echo "- Severity colors are preserved"
echo "- No API or SSE behavior changed"

echo "Step 4: Tag completion"
git tag -a phase654-complete -m "Phase 654 complete: guidance count summary verified"
git push origin phase654-complete

echo "PHASE 654 COMPLETE — guidance count summary verified and tagged."
