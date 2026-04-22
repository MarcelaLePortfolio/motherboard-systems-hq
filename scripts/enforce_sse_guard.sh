#!/usr/bin/env bash
set -euo pipefail

echo "=== SSE OWNERSHIP AUDIT (Phase16 Enforcement) ==="

echo ""
echo "[1] Raw EventSource task-events consumers:"
rg -n "new EventSource\\(\"/events/task-events\"" public/js || true

echo ""
echo "[2] Any EventSource usage outside Phase16 guard pattern:"
rg -n "new EventSource\\(" public/js | grep -v "__PHASE16_SSE_OWNER_STARTED" || true

echo ""
echo "[3] Ops / alternate SSE streams (reference only):"
rg -n "new EventSource\\(" public/js | grep -E "ops|reflections|task-events" || true

echo ""
echo "=== END AUDIT ==="
echo "NOTE: No automatic rewrites performed (stabilization mode)."
