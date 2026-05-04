#!/bin/bash
set -e

echo "PHASE 634 — ATLAS SUBSYSTEM VALIDATION START"

echo "Step 1: Rebuild active runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Validate subsystem endpoint"
bash scripts/verify/test-subsystem-endpoint.sh

echo "Step 4: Validate Atlas field"
bash scripts/verify/test-atlas-detection.sh

echo "PHASE 634 — ATLAS SUBSYSTEM VALIDATION COMPLETE"
