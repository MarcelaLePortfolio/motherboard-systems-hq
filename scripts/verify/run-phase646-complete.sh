#!/bin/bash
set -e

echo "PHASE 646 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Open subsystem UI"
bash scripts/verify/test-subsystem-ui.sh

echo "Step 4: Open guidance UI"
bash scripts/verify/test-guidance-ui.sh

echo "Step 5: Tag completion"
git tag -a phase646-complete -m "Phase 646 complete: UI reusability and component cleanup verified"
git push origin phase646-complete

echo "PHASE 646 COMPLETE — UI reusability verified and tagged."
