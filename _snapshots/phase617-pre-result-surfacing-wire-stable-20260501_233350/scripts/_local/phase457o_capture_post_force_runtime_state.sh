#!/usr/bin/env bash
set -euo pipefail

OUT="docs/recovery_full_audit/65_post_force_runtime_state_capture.txt"
HTML_URL="http://localhost:8080/dashboard.html"
RESTORE_JS_URL="http://localhost:8080/js/phase457_restore_task_panels.js"
NEUTRALIZER_JS_URL="http://localhost:8080/js/phase457_neutralize_legacy_observational_consumers.js"
TASKS_API_URL="http://localhost:8080/api/tasks"
TASK_EVENTS_URL="http://localhost:8080/events/task-events"

TMP_HTML="$(mktemp)"
TMP_RESTORE="$(mktemp)"
TMP_NEUTRALIZER="$(mktemp)"
TMP_TASKS="$(mktemp)"
TMP_EVENTS="$(mktemp)"

cleanup() {
  rm -f "$TMP_HTML" "$TMP_RESTORE" "$TMP_NEUTRALIZER" "$TMP_TASKS" "$TMP_EVENTS"
}
trap cleanup EXIT

curl -fsSL "$HTML_URL" -o "$TMP_HTML"
curl -fsSL "$RESTORE_JS_URL" -o "$TMP_RESTORE"
curl -fsSL "$NEUTRALIZER_JS_URL" -o "$TMP_NEUTRALIZER"
curl -fsSL "$TASKS_API_URL" -o "$TMP_TASKS" || true
curl -fsSL --max-time 3 "$TASK_EVENTS_URL" -o "$TMP_EVENTS" || true

{
  echo "PHASE 457O POST-FORCE RUNTIME STATE CAPTURE"
  echo "==========================================="
  echo
  echo "HTML_URL=$HTML_URL"
  echo "RESTORE_JS_URL=$RESTORE_JS_URL"
  echo "NEUTRALIZER_JS_URL=$NEUTRALIZER_JS_URL"
  echo "TASKS_API_URL=$TASKS_API_URL"
  echo "TASK_EVENTS_URL=$TASK_EVENTS_URL"
  echo

  echo "===== LIVE HTML SCRIPT ORDER ====="
  grep -n 'phase457_restore_task_panels.js\|phase457_neutralize_legacy_observational_consumers.js' "$TMP_HTML" || true
  echo

  echo "===== RESTORE JS SENTINELS ====="
  grep -n '__PHASE457_RESTORE_TASK_PANELS_ACTIVE__' "$TMP_RESTORE" || true
  grep -n 'No recent tasks yet.' "$TMP_RESTORE" || true
  grep -n 'No task history yet.' "$TMP_RESTORE" || true
  grep -n 'Waiting for task events' "$TMP_RESTORE" || true
  grep -n 'connectDirectTaskEvents' "$TMP_RESTORE" || true
  grep -n 'new EventSource("/events/task-events")' "$TMP_RESTORE" || true
  echo

  echo "===== NEUTRALIZER JS SENTINELS ====="
  grep -n '__PHASE457_NEUTRALIZER_ACTIVE__' "$TMP_NEUTRALIZER" || true
  grep -n 'data-phase457-neutralized' "$TMP_NEUTRALIZER" || true
  grep -n 'Confidence: high confidence' "$TMP_NEUTRALIZER" || true
  grep -n 'No recent tasks yet.' "$TMP_NEUTRALIZER" || true
  grep -n 'No task history yet.' "$TMP_NEUTRALIZER" || true
  grep -n 'updated_at' "$TMP_NEUTRALIZER" || true
  grep -n 'run_view' "$TMP_NEUTRALIZER" || true
  echo

  echo "===== TASKS API SNAPSHOT ====="
  sed -n '1,120p' "$TMP_TASKS" || true
  echo

  echo "===== TASK EVENTS SNAPSHOT ====="
  sed -n '1,120p' "$TMP_EVENTS" || true
  echo

  echo "===== DASHBOARD CONTAINER LOG TAIL ====="
  docker logs motherboard_systems_hq-dashboard-1 --tail 80 2>&1 || true
  echo

  echo "===== POSTGRES COUNTS ====="
  docker exec motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -c "select count(*) as task_count from tasks;" 2>&1 || true
  docker exec motherboard_systems_hq-postgres-1 psql -U postgres -d postgres -c "select count(*) as task_event_count from task_events;" 2>&1 || true
  echo

  echo "===== QUICK RESULT ====="
  html_restore=0
  html_neutralizer=0
  restore_guard=0
  neutralizer_guard=0
  restore_recent_empty=0
  restore_history_empty=0
  neutralizer_confidence=0
  neutralizer_recent=0
  neutralizer_history=0
  direct_bridge=0
  tasks_api_has_test=0
  events_stream_has_test=0

  grep -q 'phase457_restore_task_panels.js' "$TMP_HTML" && html_restore=1 || true
  grep -q 'phase457_neutralize_legacy_observational_consumers.js' "$TMP_HTML" && html_neutralizer=1 || true
  grep -q '__PHASE457_RESTORE_TASK_PANELS_ACTIVE__' "$TMP_RESTORE" && restore_guard=1 || true
  grep -q '__PHASE457_NEUTRALIZER_ACTIVE__' "$TMP_NEUTRALIZER" && neutralizer_guard=1 || true
  grep -q 'No recent tasks yet.' "$TMP_RESTORE" && restore_recent_empty=1 || true
  grep -q 'No task history yet.' "$TMP_RESTORE" && restore_history_empty=1 || true
  grep -q 'Confidence: high confidence' "$TMP_NEUTRALIZER" && neutralizer_confidence=1 || true
  grep -q 'No recent tasks yet.' "$TMP_NEUTRALIZER" && neutralizer_recent=1 || true
  grep -q 'No task history yet.' "$TMP_NEUTRALIZER" && neutralizer_history=1 || true
  grep -q 'connectDirectTaskEvents' "$TMP_RESTORE" && direct_bridge=1 || true
  grep -q 'phase457-test' "$TMP_TASKS" && tasks_api_has_test=1 || true
  grep -q 'phase457-test' "$TMP_EVENTS" && events_stream_has_test=1 || true

  echo "HTML_RESTORE_TAG=$html_restore"
  echo "HTML_NEUTRALIZER_TAG=$html_neutralizer"
  echo "RESTORE_GUARD=$restore_guard"
  echo "NEUTRALIZER_GUARD=$neutralizer_guard"
  echo "RESTORE_RECENT_EMPTY=$restore_recent_empty"
  echo "RESTORE_HISTORY_EMPTY=$restore_history_empty"
  echo "NEUTRALIZER_CONFIDENCE_PATCH=$neutralizer_confidence"
  echo "NEUTRALIZER_RECENT_PATCH=$neutralizer_recent"
  echo "NEUTRALIZER_HISTORY_PATCH=$neutralizer_history"
  echo "DIRECT_EVENT_BRIDGE=$direct_bridge"
  echo "TASKS_API_HAS_PHASE457_TEST=$tasks_api_has_test"
  echo "EVENTS_STREAM_HAS_PHASE457_TEST=$events_stream_has_test"
} > "$OUT"

sed -n '1,320p' "$OUT"
