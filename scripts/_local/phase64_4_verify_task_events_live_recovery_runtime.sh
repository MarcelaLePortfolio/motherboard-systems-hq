#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

echo "== live dashboard script tags =="
curl -fsS "$BASE_URL/dashboard" | grep -n 'phase61_recent_history_wire\|phase64_4_task_events_live_recovery\|bundle.js\|phase60_live_clock' || true
echo

echo "== live recovery asset header =="
curl -fsS "$BASE_URL/js/phase64_4_task_events_live_recovery.js?v=phase64_4_live_recovery_20260314b" | sed -n '1,80p'
echo

echo "== dashboard logs tail =="
docker compose logs --tail=120 dashboard
echo

echo "== browser follow-up =="
printf '%s\n' \
'Open http://127.0.0.1:8080/dashboard' \
'Hard refresh with Cmd+Shift+R' \
'Console checks:' \
'document.querySelectorAll("script[src*=\"phase64_4_task_events_live_recovery\"]").length' \
'window.__PHASE64_TASK_EVENTS_RECOVERY__ && window.__PHASE64_TASK_EVENTS_RECOVERY__.rows()' \
'document.querySelector("[data-phase64-task-events-status]")?.textContent'
