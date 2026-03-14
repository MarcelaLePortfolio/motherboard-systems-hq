#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

echo "== dashboard fetch =="
HTML="$(mktemp)"
trap 'rm -f "$HTML"' EXIT

curl -fsS "${BASE_URL}/dashboard" > "$HTML"

echo
echo "== layout anchors =="
for anchor in \
'id="phase61-workspace-shell"' \
'id="operator-workspace-card"' \
'id="observational-workspace-card"' \
'id="observational-panels"' \
'id="operator-panels"' \
'id="mb-task-events-panel-anchor"' \
'id="phase61-atlas-band"'
do
  grep -q "$anchor" "$HTML" && echo "PASS $anchor" || { echo "FAIL $anchor"; exit 20; }
done

echo
echo "== required scripts present =="
for script in \
'phase61_tabs_workspace' \
'phase61_recent_history_wire' \
'phase60_live_clock' \
'bundle.js'
do
  grep -q "$script" "$HTML" && echo "PASS $script" || { echo "FAIL $script"; exit 21; }
done

echo
echo "== forbidden broken recovery hook absent =="
if grep -q 'phase64_4_task_events_live_recovery' "$HTML"; then
  echo "FAIL broken recovery hook still mounted"
  exit 23
fi
echo "PASS broken recovery hook absent"

echo
echo "== task-events mount uniqueness =="
COUNT="$(grep -c 'mb-task-events-panel-anchor' "$HTML")"
if [ "$COUNT" -ne 1 ]; then
  echo "FAIL task-events mounted $COUNT times"
  exit 22
fi
echo "PASS task-events single mount"

echo
echo "LAYOUT + SCRIPT CONTRACT PASS"
