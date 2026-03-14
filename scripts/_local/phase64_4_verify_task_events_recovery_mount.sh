#!/usr/bin/env bash
set -euo pipefail

echo "== local file script tags =="
grep -n 'phase61_recent_history_wire\|phase64_4_task_events_live_recovery\|bundle.js\|phase60_live_clock' public/dashboard.html || true
echo

echo "== local recovery file exists =="
ls -l public/js/phase64_4_task_events_live_recovery.js
echo

echo "== local recovery file header =="
sed -n '1,40p' public/js/phase64_4_task_events_live_recovery.js
