#!/bin/bash
set -e

echo "PHASE 640 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Validate guidance endpoint"
bash scripts/verify/test-guidance-subsystem.sh

echo "Step 4: Open guidance UI"
bash scripts/verify/test-guidance-ui.sh

echo "Step 5: Tag completion"
git tag -a phase640-complete -m "Phase 640 complete: guidance visibility in UI verified"
git push origin phase640-complete

echo "PHASE 640 COMPLETE — guidance UI fully surfaced and verified."
