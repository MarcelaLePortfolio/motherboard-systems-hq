#!/usr/bin/env bash
set -euo pipefail

echo "== Phase 65 Tasks Running inspection =="

echo
echo "-- Branch / HEAD --"
git branch --show-current
git rev-parse --short HEAD

echo
echo "-- Candidate metric hooks in dashboard HTML --"
rg -n 'Tasks Running|Success Rate|Latency|metric|tile' public/dashboard.html public/js public/css || true

echo
echo "-- Task event handling in JS --"
rg -n 'task\.|task-events|EventSource|SSE|recent history|recent tasks|running|queued|completed|failed|cancelled|started' \
  public/js/phase61_recent_history_wire.js \
  public/js/phase61_tabs_workspace.js \
  public/js || true

echo
echo "-- Tasks API / mutation references --"
rg -n '/api/tasks|task_id|run_id|state|status|queued|running|completed|failed|cancelled|started' \
  server/tasks-mutations.mjs \
  server public/js || true

echo
echo "-- Protection guards present --"
ls -1 \
  scripts/_local/phase64_4_task_events_regression_guard.sh \
  scripts/_local/phase64_7_dashboard_layout_script_mount_guard.sh \
  scripts/_local/phase64_8_pre_push_contract_guard.sh

echo
echo "-- Recommended next edit surface --"
echo "Inspect whether Tasks Running tile already has a stable DOM hook in public/dashboard.html."
echo "If yes, bind in JS only."
echo "If no, STOP and do not mutate layout."

echo
echo "Inspection complete."
