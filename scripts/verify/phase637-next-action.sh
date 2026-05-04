#!/bin/bash
set -e

echo "PHASE 637 — NEXT ACTION"

echo "Run the active runtime audit:"
echo "bash scripts/verify/run-phase637-audit.sh"

echo ""
echo "Expected result:"
echo "- No missing active-server route registration"
echo "- /api/subsystem-status returns ok:true"
echo "- /events/subsystem-status streams subsystem snapshots"

echo ""
echo "If endpoint or SSE fails, patch active server.js directly instead of adding more helper files."
