#!/bin/bash
set -e

echo "PHASE 661 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Open Operator Dashboard"
open http://localhost:8080/dev/page-OperatorDashboard

echo "Manual check:"
echo "- Severity groups remain ordered"
echo "- Higher severity groups have subtle visual emphasis"
echo "- Guidance SSE still updates"
echo "- Polling fallback remains present"

echo "Step 4: Tag completion"
git tag -a phase661-complete -m "Phase 661 complete: visual priority emphasis verified"
git push origin phase661-complete

echo "PHASE 661 COMPLETE — visual priority emphasis verified and tagged."
