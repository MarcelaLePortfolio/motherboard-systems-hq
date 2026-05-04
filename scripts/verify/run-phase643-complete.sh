#!/bin/bash
set -e

echo "PHASE 643 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Open subsystem UI"
bash scripts/verify/test-subsystem-ui.sh

echo "Step 4: Open guidance UI"
bash scripts/verify/test-guidance-ui.sh

echo "Step 5: Tag completion"
git tag -a phase643-complete -m "Phase 643 complete: lightweight UI alerting verified"

git push origin phase643-complete

echo "PHASE 643 COMPLETE — lightweight UI alerting verified and tagged."
