#!/bin/bash
set -e

echo "PHASE 642 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Open subsystem UI"
bash scripts/verify/test-subsystem-ui.sh

echo "Step 4: Open guidance UI"
bash scripts/verify/test-guidance-ui.sh

echo "Step 5: Tag completion"
git tag -a phase642-complete -m "Phase 642 complete: cross-panel timestamp and stale-state UI synchronization verified"
git push origin phase642-complete

echo "PHASE 642 COMPLETE — cross-panel synchronization verified and tagged."
