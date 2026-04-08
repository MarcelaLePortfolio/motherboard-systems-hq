#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/55_verify_live_dashboard_after_fallback_restore.txt"
URL="${URL:-http://localhost:8080/dashboard.html}"

TMP_HTML="$(mktemp)"
cleanup() {
  rm -f "$TMP_HTML"
}
trap cleanup EXIT

curl -fsSL "$URL" -o "$TMP_HTML"

{
  echo "PHASE 457D LIVE VERIFICATION"
  echo "============================"
  echo
  echo "URL=$URL"
  echo
  echo "===== SCRIPT TAGS ====="
  grep "phase457_restore_task_panels.js" "$TMP_HTML" || echo "SCRIPT NOT FOUND"
  echo
  echo "===== PANEL TARGET IDS ====="
  grep -n "tasks-widget" "$TMP_HTML" || true
  grep -n "recentLogs" "$TMP_HTML" || true
  grep -n "mb-task-events-panel-anchor" "$TMP_HTML" || true
  grep -n "operator-guidance" "$TMP_HTML" || true
  echo
  echo "===== LOCAL PATCH CHECK ====="
  grep -n "connectDirectTaskEvents" public/js/phase457_restore_task_panels.js || true
  grep -n "mb.task.event" public/js/phase457_restore_task_panels.js || true
  grep -n "Confidence: high" public/js/phase457_restore_task_panels.js || true
  echo
  echo "===== QUICK RESULT ====="
  recent=0
  history=0
  events=0
  guidance=0
  bridge=0
  grep -q 'tasks-widget' "$TMP_HTML" && recent=1 || true
  grep -q 'recentLogs' "$TMP_HTML" && history=1 || true
  grep -q 'mb-task-events-panel-anchor' "$TMP_HTML" && events=1 || true
  grep -q 'Operator Guidance' "$TMP_HTML" && guidance=1 || true
  grep -q 'connectDirectTaskEvents' public/js/phase457_restore_task_panels.js && bridge=1 || true
  echo "RECENT_PANEL=$recent"
  echo "HISTORY_PANEL=$history"
  echo "TASK_EVENTS=$events"
  echo "GUIDANCE=$guidance"
  echo "DIRECT_EVENT_BRIDGE=$bridge"
} > "$OUT"

sed -n '1,200p' "$OUT"
