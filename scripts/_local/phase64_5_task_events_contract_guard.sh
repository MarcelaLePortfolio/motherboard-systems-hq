#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
STAMP="$(date +%s)"

echo "== repo root =="
pwd
echo

echo "== git head =="
git rev-parse --short HEAD
echo

echo "== dashboard health =="
curl -I "${BASE_URL}/dashboard"
echo

echo "== run required endpoint regression guard =="
bash scripts/_local/phase64_4_task_events_regression_guard.sh
echo

echo "== live dashboard script tags =="
curl -fsS "${BASE_URL}/dashboard" | grep -n 'phase61_recent_history_wire\|phase64_4_task_events_live_recovery\|bundle.js\|phase60_live_clock' || true
echo

echo "== open cache-busted dashboard for mandatory UI verification =="
open "${BASE_URL}/dashboard?taskevents_contract_guard=${STAMP}"
echo

printf '%s\n' \
'MANDATORY MANUAL UI CHECKS' \
'1. Hard refresh with Cmd+Shift+R' \
'2. Verify dashboard finishes loading' \
'3. Verify tabs are clickable' \
'4. Click Task Events and verify it remains interactive' \
'5. Confirm no replay storm is occurring' \
'' \
'Console checks:' \
'document.readyState' \
'document.querySelectorAll("[data-tab], [data-target], button[aria-controls]").length' \
'document.querySelector("[data-tab=\"task-events\"], [data-target=\"task-events\"], button[aria-controls=\"obs-panel-events\"]")?.click()' \
'document.querySelector("[data-tab-panel=\"task-events\"], #task-events-panel, #obs-panel-events")?.outerHTML'
