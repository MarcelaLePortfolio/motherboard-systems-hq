#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/53_verify_restored_task_panels.txt"

TMP_DASH=$(mktemp)
TMP_FIX=$(mktemp)

cp public/dashboard.html "$TMP_DASH"
cp public/js/phase457_restore_task_panels.js "$TMP_FIX"

{
echo "PHASE 457 VERIFY RESTORE"
echo

echo "===== SCRIPT PRESENT ====="

grep "phase457_restore_task_panels.js" "$TMP_DASH" || echo "SCRIPT NOT FOUND"

echo
echo "===== TARGET IDS ====="

grep -n "tasks-widget" "$TMP_FIX" || true
grep -n "recentLogs" "$TMP_FIX" || true
grep -n "mb.task.event" "$TMP_FIX" || true

echo
echo "===== QUICK RESULT ====="

recent=0
history=0
event=0

grep -q "tasks-widget" "$TMP_FIX" && recent=1 || true
grep -q "recentLogs" "$TMP_FIX" && history=1 || true
grep -q "mb.task.event" "$TMP_FIX" && event=1 || true

echo "RECENT_PANEL=$recent"
echo "HISTORY_PANEL=$history"
echo "EVENT_BIND=$event"

} > "$OUT"

sed -n '1,120p' "$OUT"

