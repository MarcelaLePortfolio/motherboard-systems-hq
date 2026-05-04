#!/bin/bash
set -e

echo "PHASE 636 — SSE VALIDATION START"

echo "Connecting to SSE stream (5 seconds)..."
timeout 5 curl -N http://localhost:8080/events/subsystem-status || true

echo ""
echo "Manual check:"
echo "- Should see JSON snapshots streaming"
echo "- Should update every ~5 seconds"

echo "PHASE 636 — SSE VALIDATION COMPLETE"
