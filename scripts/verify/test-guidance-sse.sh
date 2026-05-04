#!/bin/bash
set -e

echo "PHASE 641 — GUIDANCE SSE VALIDATION START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Connect to guidance SSE (5 seconds)..."
timeout 5 curl -N http://localhost:8080/events/guidance || true

echo ""
echo "Manual check:"
echo "- Should see JSON guidance snapshots streaming"
echo "- Should update every ~5 seconds"

echo ""
echo "PHASE 641 — GUIDANCE SSE VALIDATION COMPLETE"
