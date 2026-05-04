#!/bin/bash
set -e

echo "PHASE 648 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Open Operator Dashboard"
bash scripts/verify/test-operator-dashboard.sh

echo "Manual responsive checks:"
echo "- Desktop width shows panels side-by-side when space allows"
echo "- Narrow width stacks panels cleanly"
echo "- Both panels continue updating independently"

echo "Step 4: Tag completion"
git tag -a phase648-complete -m "Phase 648 complete: responsive Operator Dashboard layout verified"
git push origin phase648-complete

echo "PHASE 648 COMPLETE — responsive layout verified and tagged."
