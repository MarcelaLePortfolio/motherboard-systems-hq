#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/52_pinpoint_observational_consumer_gaps.txt"

TMP_BUNDLE=$(mktemp)
TMP_DASH=$(mktemp)

cp public/bundle.js "$TMP_BUNDLE"
cp public/dashboard.html "$TMP_DASH"

{
echo "PHASE 457 OBSERVATIONAL GAP PINPOINT"
echo

echo "===== SHELL IDS ====="
grep -Eo 'id="[^"]+"' "$TMP_DASH" | sed 's/id="//;s/"//' | sort | \
grep -E 'task|recent|history|activity|obs|metric' || true

echo
echo "===== BUNDLE DOM TARGETS ====="

grep -n "getElementById" "$TMP_BUNDLE" | \
grep -E 'task|recent|history|activity|metric' || true

echo
echo "===== TASK EVENTS HOOKS ====="

grep -n "task-events" "$TMP_BUNDLE" || true
grep -n "mb.task.event" "$TMP_BUNDLE" || true

echo
echo "===== METRIC TARGETS ====="

grep -n "metric-tasks" "$TMP_BUNDLE" || true
grep -n "metric-latency" "$TMP_BUNDLE" || true
grep -n "metric-success" "$TMP_BUNDLE" || true

echo
echo "===== RECENT TASK SEARCH ====="

grep -n "recent" "$TMP_BUNDLE" || true

echo
echo "===== HISTORY SEARCH ====="

grep -n "history" "$TMP_BUNDLE" || true

echo
echo "===== ACTIVITY SEARCH ====="

grep -n "activity" "$TMP_BUNDLE" || true

echo
echo "===== QUICK GAP SUMMARY ====="

recent_dom=0
history_dom=0
activity_dom=0
events_dom=0

grep -q "tasks-widget" "$TMP_BUNDLE" && recent_dom=1 || true
grep -q "history" "$TMP_BUNDLE" && history_dom=1 || true
grep -q "metric-tasks" "$TMP_BUNDLE" && activity_dom=1 || true
grep -q "mb-task-events-panel-anchor" "$TMP_BUNDLE" && events_dom=1 || true

echo "RECENT_DOM_TARGET=$recent_dom"
echo "HISTORY_DOM_TARGET=$history_dom"
echo "ACTIVITY_DOM_TARGET=$activity_dom"
echo "EVENTS_DOM_TARGET=$events_dom"

} > "$OUT"

sed -n '1,200p' "$OUT"

