#!/bin/bash
set -e

echo "PHASE 644 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Open subsystem UI"
bash scripts/verify/test-subsystem-ui.sh

echo "Step 4: Open guidance UI"
bash scripts/verify/test-guidance-ui.sh

echo "Step 5: Tag completion"
git tag -a phase644-complete -m "Phase 644 complete: UI polish and signal clarity verified"
git push origin phase644-complete

echo "PHASE 644 COMPLETE — UI polish and signal clarity verified and tagged."
