#!/bin/bash
set -e

echo "PHASE 645 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Open subsystem UI"
bash scripts/verify/test-subsystem-ui.sh

echo "Step 4: Open guidance UI"
bash scripts/verify/test-guidance-ui.sh

echo "Step 5: Tag completion"
git tag -a phase645-complete -m "Phase 645 complete: UI consistency and shared styling verified"
git push origin phase645-complete

echo "PHASE 645 COMPLETE — UI consistency and shared styling verified and tagged."
