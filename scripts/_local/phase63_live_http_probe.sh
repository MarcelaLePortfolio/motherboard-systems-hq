#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8080}"

echo "=== rebuild dashboard ==="
docker compose build --no-cache dashboard
docker compose up -d --force-recreate dashboard
sleep 5

echo
echo "=== live dashboard html script tags ==="
curl -fsSL "${BASE_URL}/dashboard" | grep -n 'phase61_tabs_workspace.js\|phase61_recent_history_wire.js\|bundle.js\|phase60_live_clock.js'

echo
echo "=== live recent wire contains probes ==="
curl -fsSL "${BASE_URL}/js/phase61_recent_history_wire.js?v=phase63_dom_fix_20260313b" | grep -n 'data-phase61-probe\|data-phase61-recent-row\|data-phase61-history-row\|window.__PHASE61_RECENT_HISTORY_WIRE'

echo
echo "=== live api/tasks payload ==="
curl -fsSL "${BASE_URL}/api/tasks?limit=12" | python3 -m json.tool

echo
echo "=== live api/runs payload ==="
curl -fsSL "${BASE_URL}/api/runs?limit=20" | python3 -m json.tool || true

echo
echo "=== dashboard logs tail ==="
docker compose logs dashboard --tail=120

echo
echo "=== browser actions ==="
printf '%s\n' '1) Open http://127.0.0.1:8080/dashboard in a fresh tab'
printf '%s\n' '2) Hard refresh with Cmd+Shift+R'
printf '%s\n' '3) Paste these in browser console:'
printf '%s\n' 'window.__PHASE61_RECENT_HISTORY_WIRE && window.__PHASE61_RECENT_HISTORY_WIRE.refreshAll()'
printf '%s\n' 'document.querySelector("[data-phase61-probe=\"recent\"]")?.textContent'
printf '%s\n' 'document.querySelector("[data-phase61-probe=\"history\"]")?.textContent'
printf '%s\n' 'document.querySelectorAll("[data-phase61-recent-row]").length'
printf '%s\n' 'document.querySelectorAll("[data-phase61-history-row]").length'
printf '%s\n' 'document.getElementById("recent-tasks-card")?.outerHTML'
printf '%s\n' 'document.getElementById("task-activity-card")?.outerHTML'
