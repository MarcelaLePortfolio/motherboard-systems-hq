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

echo "== phase64.6 safe contract corridor start =="
echo "This runner stops immediately on any failure."
echo

echo "== step 1: cleanup stray shell artifacts =="
bash scripts/_local/phase64_6_cleanup_stray_shell_artifacts.sh
echo

echo "== step 2: dashboard health =="
curl -I "${BASE_URL}/dashboard"
echo

echo "== step 3: task-events regression guard =="
bash scripts/_local/phase64_4_task_events_regression_guard.sh
echo

echo "== step 4: task-events contract guard =="
bash scripts/_local/phase64_5_task_events_contract_guard.sh
echo

echo "== step 5: workspace interactivity contract guard =="
bash scripts/_local/phase64_6_workspace_interactivity_contract_guard.sh
echo

echo "== step 6: final cache-busted dashboard open =="
open "${BASE_URL}/dashboard?safe_contract_corridor=${STAMP}"
echo

printf '%s\n' \
'SAFE CORRIDOR COMPLETE' \
'Now perform the mandatory manual UI verification:' \
'1. Hard refresh with Cmd+Shift+R' \
'2. Verify dashboard finishes loading' \
'3. Verify tabs are clickable' \
'4. Verify only one intended panel is visible per workspace' \
'5. Click Task Events and verify it remains interactive' \
'6. Confirm no replay storm is occurring'
