#!/usr/bin/env bash
set -euo pipefail

echo "=== DEMO / SSE HEALTH CHECK ==="

echo ""
echo "[1] Remaining direct task-events EventSource usage:"
rg -n "new EventSource\\(\"/events/task-events\"" public/js || true

echo ""
echo "[2] All EventSource consumers (current state):"
rg -n "new EventSource\\(" public/js | head -n 50 || true

echo ""
echo "[3] Phase16 event-bus usage (mb.task.event listeners):"
rg -n "mb\\.task\\.event" public/js || true

echo ""
echo "[4] agent-status-row SSE coupling check:"
rg -n "task-events|EventSource" public/js/agent-status-row.js || true

echo ""
echo "[5] task-events UI client presence:"
ls -la public/js | grep task-events || true

echo ""
echo "=== END HEALTH CHECK ==="
