#!/bin/bash
set -e

echo "PHASE 633 — SUBSYSTEM VALIDATION START"

echo "Step 1: Check route wiring"
bash scripts/verify/check-subsystem-route-wiring.sh

echo "Step 2: Test endpoint"
bash scripts/verify/test-subsystem-endpoint.sh

echo "PHASE 633 — SUBSYSTEM VALIDATION COMPLETE"
echo "If endpoint returns ok:true, subsystem surface is successfully wired."
