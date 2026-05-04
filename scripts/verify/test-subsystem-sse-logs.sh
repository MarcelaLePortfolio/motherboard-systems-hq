#!/bin/bash
set -e

echo "PHASE 638 — SUBSYSTEM SSE LOG VALIDATION START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Trigger subsystem SSE stream"
bash scripts/verify/test-subsystem-sse.sh

echo "Step 4: Check app logs for structured subsystem snapshots"
docker logs motherboard_systems_hq-dashboard-1 2>&1 | grep "\[subsystem\]\[snapshot\]" | tail -5 || {
  echo "Structured subsystem snapshot logs not found"
  exit 1
}

echo "PHASE 638 — SUBSYSTEM SSE LOG VALIDATION COMPLETE"
