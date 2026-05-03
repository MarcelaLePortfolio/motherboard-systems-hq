#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 539 — SURFACE DIAGNOSTIC"
echo "──────────────────────────────"

echo ""
echo "1. Served root references to task-events scripts:"
curl -s http://localhost:8080/ | grep -n "task-events-sse-client\|dashboard-bundle-entry\|dashboard-tasks-widget\|Task Activity\|Execution Trail" || true

echo ""
echo "2. Served task-events client markers:"
curl -s http://localhost:8080/js/task-events-sse-client.js | grep -n "Execution Trail\|selected: none\|SELECTED_ID\|Task Activity" || true

echo ""
echo "3. Local public index references:"
grep -RIn "task-events-sse-client\|dashboard-bundle-entry\|dashboard-tasks-widget\|Task Activity\|Execution Trail" public/index.html public/js || true

echo ""
echo "DIAGNOSIS TARGET:"
echo "- If served JS has Execution Trail but browser shows Task Activity, cache or different script is rendering."
echo "- If served root does not load task-events-sse-client.js, the updated file is not on the active surface."
echo "- If another JS file contains Task Activity, that file is likely the active renderer."
