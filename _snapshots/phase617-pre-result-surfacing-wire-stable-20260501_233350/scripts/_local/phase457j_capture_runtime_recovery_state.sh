#!/usr/bin/env bash
set -euo pipefail

OUT="docs/recovery_full_audit/61_capture_runtime_recovery_state.txt"
HTML_URL="http://localhost:8080/dashboard.html"
JS_URL="http://localhost:8080/js/phase457_neutralize_legacy_observational_consumers.js"
RESTORE_JS_URL="http://localhost:8080/js/phase457_restore_task_panels.js"

TMP_HTML="$(mktemp)"
TMP_JS="$(mktemp)"
TMP_RESTORE="$(mktemp)"
cleanup() {
  rm -f "$TMP_HTML" "$TMP_JS" "$TMP_RESTORE"
}
trap cleanup EXIT

curl -fsSL "$HTML_URL" -o "$TMP_HTML"
curl -fsSL "$JS_URL" -o "$TMP_JS"
curl -fsSL "$RESTORE_JS_URL" -o "$TMP_RESTORE"

{
  echo "PHASE 457J RUNTIME RECOVERY STATE CAPTURE"
  echo "========================================="
  echo
  echo "HTML_URL=$HTML_URL"
  echo "JS_URL=$JS_URL"
  echo "RESTORE_JS_URL=$RESTORE_JS_URL"
  echo

  echo "===== LIVE HTML SCRIPT ORDER ====="
  grep -nE 'phase457_restore_task_panels|phase457_neutralize_legacy_observational_consumers' "$TMP_HTML" || true
  echo

  echo "===== NEUTRALIZER LIVE SENTINELS ====="
  grep -n '__PHASE457_NEUTRALIZER_ACTIVE__' "$TMP_JS" || true
  grep -n 'data-phase457-neutralized' "$TMP_JS" || true
  grep -n 'Confidence: high confidence' "$TMP_JS" || true
  grep -n 'probe:recent:' "$TMP_JS" || true
  grep -n 'probe:history:' "$TMP_JS" || true
  grep -n 'relation "run_view" does not exist' "$TMP_JS" || true
  grep -n 'column "updated_at" does not exist' "$TMP_JS" || true
  echo

  echo "===== RESTORE PANEL LIVE SENTINELS ====="
  grep -n 'mb.task.event' "$TMP_RESTORE" || true
  grep -n 'connectDirectTaskEvents' "$TMP_RESTORE" || true
  grep -n 'Waiting for recent tasks' "$TMP_RESTORE" || true
  grep -n 'Waiting for task history' "$TMP_RESTORE" || true
  grep -n 'Waiting for task events' "$TMP_RESTORE" || true
  echo

  echo "===== PANEL IDS IN LIVE HTML ====="
  grep -n 'tasks-widget' "$TMP_HTML" || true
  grep -n 'recentLogs' "$TMP_HTML" || true
  grep -n 'mb-task-events-panel-anchor' "$TMP_HTML" || true
  grep -n 'operator-guidance-response' "$TMP_HTML" || true
  grep -n 'operator-guidance-meta' "$TMP_HTML" || true
  echo

  echo "===== QUICK RESULT ====="
  HTML_RESTORE_TAG=0
  HTML_NEUTRALIZER_TAG=0
  JS_NEUTRALIZER_GUARD=0
  JS_CONFIDENCE_PATCH=0
  JS_NEUTRALIZER_ATTR=0
  RESTORE_EVENT_BRIDGE=0

  grep -q 'phase457_restore_task_panels.js' "$TMP_HTML" && HTML_RESTORE_TAG=1 || true
  grep -q 'phase457_neutralize_legacy_observational_consumers.js' "$TMP_HTML" && HTML_NEUTRALIZER_TAG=1 || true
  grep -q '__PHASE457_NEUTRALIZER_ACTIVE__' "$TMP_JS" && JS_NEUTRALIZER_GUARD=1 || true
  grep -q 'Confidence: high confidence' "$TMP_JS" && JS_CONFIDENCE_PATCH=1 || true
  grep -q 'data-phase457-neutralized' "$TMP_JS" && JS_NEUTRALIZER_ATTR=1 || true
  grep -q 'connectDirectTaskEvents' "$TMP_RESTORE" && RESTORE_EVENT_BRIDGE=1 || true

  echo "HTML_RESTORE_TAG=$HTML_RESTORE_TAG"
  echo "HTML_NEUTRALIZER_TAG=$HTML_NEUTRALIZER_TAG"
  echo "JS_NEUTRALIZER_GUARD=$JS_NEUTRALIZER_GUARD"
  echo "JS_CONFIDENCE_PATCH=$JS_CONFIDENCE_PATCH"
  echo "JS_NEUTRALIZER_ATTR=$JS_NEUTRALIZER_ATTR"
  echo "RESTORE_EVENT_BRIDGE=$RESTORE_EVENT_BRIDGE"
} > "$OUT"

sed -n '1,260p' "$OUT"
