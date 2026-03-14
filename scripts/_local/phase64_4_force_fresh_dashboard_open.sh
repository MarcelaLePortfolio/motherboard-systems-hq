#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
STAMP="$(date +%s)"

echo "== repo root =="
pwd
echo

echo "== dashboard health =="
curl -I "${BASE_URL}/dashboard"
echo

echo "== live script tags =="
curl -fsS "${BASE_URL}/dashboard" | grep -n 'phase61_recent_history_wire\|phase64_4_task_events_live_recovery\|bundle.js\|phase60_live_clock' || true
echo

echo "== opening cache-busted dashboard =="
open "${BASE_URL}/dashboard?bust=${STAMP}"
echo

printf '%s\n' \
'After the page opens, do a hard refresh with Cmd+Shift+R.' \
'Then run these console checks:' \
'document.querySelectorAll("script[src*=\"phase64_4_task_events_live_recovery\"]").length' \
'window.__PHASE64_TASK_EVENTS_RECOVERY__ && window.__PHASE64_TASK_EVENTS_RECOVERY__.rows()' \
'document.querySelector("[data-phase64-task-events-status]")?.textContent' \
'document.querySelectorAll("[data-phase64-task-event-row]").length'
