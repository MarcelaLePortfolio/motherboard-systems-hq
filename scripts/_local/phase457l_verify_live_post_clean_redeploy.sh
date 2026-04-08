#!/usr/bin/env bash
set -euo pipefail

OUT="docs/recovery_full_audit/63_verify_live_post_clean_redeploy.txt"
HTML_URL="http://localhost:8080/dashboard.html"
RESTORE_JS_URL="http://localhost:8080/js/phase457_restore_task_panels.js"
NEUTRALIZER_JS_URL="http://localhost:8080/js/phase457_neutralize_legacy_observational_consumers.js"

TMP_HTML="$(mktemp)"
TMP_RESTORE="$(mktemp)"
TMP_NEUTRALIZER="$(mktemp)"

cleanup() {
  rm -f "$TMP_HTML" "$TMP_RESTORE" "$TMP_NEUTRALIZER"
}
trap cleanup EXIT

curl -fsSL "$HTML_URL" -o "$TMP_HTML"
curl -fsSL "$RESTORE_JS_URL" -o "$TMP_RESTORE"
curl -fsSL "$NEUTRALIZER_JS_URL" -o "$TMP_NEUTRALIZER"

{
  echo "PHASE 457L LIVE VERIFICATION AFTER CLEAN REDEPLOY"
  echo "================================================="
  echo
  echo "HTML_URL=$HTML_URL"
  echo "RESTORE_JS_URL=$RESTORE_JS_URL"
  echo "NEUTRALIZER_JS_URL=$NEUTRALIZER_JS_URL"
  echo

  echo "===== LIVE HTML SCRIPT ORDER ====="
  grep -n 'phase457_restore_task_panels.js' "$TMP_HTML" || true
  grep -n 'phase457_neutralize_legacy_observational_consumers.js' "$TMP_HTML" || true
  echo

  echo "===== LIVE RESTORE JS SENTINELS ====="
  grep -n '__PHASE457_RESTORE_TASK_PANELS_ACTIVE__' "$TMP_RESTORE" || true
  grep -n 'Waiting for recent tasks' "$TMP_RESTORE" || true
  grep -n 'Waiting for task history' "$TMP_RESTORE" || true
  grep -n 'connectDirectTaskEvents' "$TMP_RESTORE" || true
  grep -n 'EventSource("/events/task-events")' "$TMP_RESTORE" || true
  grep -n 'new EventSource("/events/task-events")' "$TMP_RESTORE" || true
  grep -n 'mb.task.event' "$TMP_RESTORE" || true
  echo

  echo "===== LIVE NEUTRALIZER JS SENTINELS ====="
  grep -n '__PHASE457_NEUTRALIZER_ACTIVE__' "$TMP_NEUTRALIZER" || true
  grep -n 'data-phase457-neutralized' "$TMP_NEUTRALIZER" || true
  grep -n 'Confidence: high confidence' "$TMP_NEUTRALIZER" || true
  grep -n 'column "updated_at" does not exist' "$TMP_NEUTRALIZER" || true
  grep -n 'relation "run_view" does not exist' "$TMP_NEUTRALIZER" || true
  echo

  echo "===== PANEL IDS IN LIVE HTML ====="
  grep -n 'tasks-widget' "$TMP_HTML" || true
  grep -n 'recentLogs' "$TMP_HTML" || true
  grep -n 'mb-task-events-panel-anchor' "$TMP_HTML" || true
  grep -n 'operator-guidance-response' "$TMP_HTML" || true
  grep -n 'operator-guidance-meta' "$TMP_HTML" || true
  echo

  echo "===== QUICK RESULT ====="
  html_restore=0
  html_neutralizer=0
  restore_guard=0
  neutralizer_guard=0
  confidence_patch=0
  recent_probe_patch=0
  history_probe_patch=0
  direct_bridge=0

  grep -q 'phase457_restore_task_panels.js' "$TMP_HTML" && html_restore=1 || true
  grep -q 'phase457_neutralize_legacy_observational_consumers.js' "$TMP_HTML" && html_neutralizer=1 || true
  grep -q '__PHASE457_RESTORE_TASK_PANELS_ACTIVE__' "$TMP_RESTORE" && restore_guard=1 || true
  grep -q '__PHASE457_NEUTRALIZER_ACTIVE__' "$TMP_NEUTRALIZER" && neutralizer_guard=1 || true
  grep -q 'Confidence: high confidence' "$TMP_NEUTRALIZER" && confidence_patch=1 || true
  grep -q 'column "updated_at" does not exist' "$TMP_NEUTRALIZER" && recent_probe_patch=1 || true
  grep -q 'relation "run_view" does not exist' "$TMP_NEUTRALIZER" && history_probe_patch=1 || true
  grep -q 'connectDirectTaskEvents' "$TMP_RESTORE" && direct_bridge=1 || true

  echo "HTML_RESTORE_TAG=$html_restore"
  echo "HTML_NEUTRALIZER_TAG=$html_neutralizer"
  echo "RESTORE_GUARD=$restore_guard"
  echo "NEUTRALIZER_GUARD=$neutralizer_guard"
  echo "CONFIDENCE_PATCH=$confidence_patch"
  echo "RECENT_PROBE_PATCH=$recent_probe_patch"
  echo "HISTORY_PROBE_PATCH=$history_probe_patch"
  echo "DIRECT_EVENT_BRIDGE=$direct_bridge"
} > "$OUT"

sed -n '1,260p' "$OUT"
