#!/bin/bash
set -e

echo "Running Phase 637 active runtime audit..."

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Run wiring audit"
bash scripts/verify/audit-active-runtime.sh

echo "Step 4: Test subsystem endpoint"
bash scripts/verify/test-subsystem-endpoint.sh || echo "⚠️ endpoint test failed"

echo "Step 5: Test SSE stream"
bash scripts/verify/test-subsystem-sse.sh || echo "⚠️ SSE test failed"

echo "PHASE 637 AUDIT COMPLETE — review any warnings above"
