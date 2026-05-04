#!/bin/bash
set -e

echo "PHASE 635 — FINAL SAFE VALIDATION START"

echo "Step 1: Rebuild active runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Validate subsystem endpoint"
bash scripts/verify/test-subsystem-endpoint.sh

echo "Step 4: Open subsystem UI for manual validation"
bash scripts/verify/test-subsystem-ui.sh

echo "Step 5: Tag Phase 635 completion"
bash scripts/verify/phase635-mark-complete.sh

echo "PHASE 635 — FINAL SAFE VALIDATION COMPLETE"
