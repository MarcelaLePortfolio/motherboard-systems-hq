#!/bin/bash
set -e

echo "PHASE 647 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Open Operator Dashboard"
bash scripts/verify/test-operator-dashboard.sh

echo "Step 4: Tag completion"
git tag -a phase647-complete -m "Phase 647 complete: Operator dashboard composition verified"
git push origin phase647-complete

echo "PHASE 647 COMPLETE — operator dashboard verified and tagged."
