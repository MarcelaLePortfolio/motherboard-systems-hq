#!/usr/bin/env bash
set -euo pipefail

BASE_COMMIT="${1:-0a13d9ff}"

git checkout "$BASE_COMMIT" -- public/dashboard.html public/js/phase61_recent_history_wire.js

rm -f public/js/phase64_4_task_events_live_recovery.js
rm -f scripts/_local/phase64_4_apply_task_events_live_recovery.sh
rm -f scripts/_local/phase64_4_force_mount_task_events_recovery.sh
rm -f scripts/_local/phase64_4_verify_task_events_live_recovery_runtime.sh
rm -f scripts/_local/phase64_4_verify_task_events_recovery_mount.sh
rm -f scripts/_local/phase64_4_force_fresh_dashboard_open.sh

python3 <<'PY'
from pathlib import Path

path = Path("public/dashboard.html")
text = path.read_text()

while '\n  <script src="js/phase64_4_task_events_live_recovery.js?v=phase64_4_live_recovery_20260314b"></script>' in text:
    text = text.replace('\n  <script src="js/phase64_4_task_events_live_recovery.js?v=phase64_4_live_recovery_20260314b"></script>', '')

while '\n  <script src="js/phase64_4_task_events_live_recovery.js"></script>' in text:
    text = text.replace('\n  <script src="js/phase64_4_task_events_live_recovery.js"></script>', '')

path.write_text(text)
print("restored dashboard html to interactive baseline without phase64.4 recovery mount")
PY

echo "restored interactive dashboard baseline from ${BASE_COMMIT}"
