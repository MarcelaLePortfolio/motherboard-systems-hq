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
curl -fsSI "${BASE_URL}/dashboard"
echo

echo "== guard 1: cleanup stray shell artifacts =="
bash scripts/_local/phase64_6_cleanup_stray_shell_artifacts.sh
echo

echo "== guard 2: task-events regression guard =="
bash scripts/_local/phase64_4_task_events_regression_guard.sh
echo

echo "== guard 3: task-events contract guard =="
bash scripts/_local/phase64_5_task_events_contract_guard.sh
echo

echo "== guard 4: workspace interactivity contract guard =="
bash scripts/_local/phase64_6_workspace_interactivity_contract_guard.sh
echo

echo "== guard 5: layout/script mount guard =="
bash scripts/_local/phase64_7_dashboard_layout_script_mount_guard.sh
echo

echo "== open final cache-busted dashboard for manual verification =="
open "${BASE_URL}/dashboard?pre_push_contract_guard=${STAMP}"
echo

printf '%s\n' \
'PRE-PUSH CONTRACT GUARD PASS' \
'Manual UI verification still required before pushing risky dashboard/task-events changes:' \
'1. Hard refresh with Cmd+Shift+R' \
'2. Verify dashboard finishes loading' \
'3. Verify tabs are clickable' \
'4. Verify only one intended panel is visible per workspace' \
'5. Click Task Events and verify it remains interactive' \
'6. Confirm no replay storm is occurring'
