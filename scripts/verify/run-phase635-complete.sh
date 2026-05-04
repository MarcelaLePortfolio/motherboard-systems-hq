#!/bin/bash
set -e

echo "Running Phase 635 completion sequence..."

echo "Step 1: Start / rebuild app"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Validate subsystem endpoint"
bash scripts/verify/test-subsystem-endpoint.sh

echo "Step 4: Open UI for manual validation"
bash scripts/verify/test-subsystem-ui.sh

echo "PHASE 635 COMPLETE — UI subsystem surfacing verified."
