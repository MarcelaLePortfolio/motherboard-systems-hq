#!/usr/bin/env bash
set -euo pipefail

SUMMARY="PHASE62B_LIVE_VALIDATION_BLOCKER_SUMMARY_20260317.txt"
FULL="PHASE62B_LIVE_VALIDATION_BLOCKER_ROUTE_INSPECTION_20260317.txt"

: > "$SUMMARY"
: > "$FULL"

{
  echo "PHASE 62B — LIVE VALIDATION BLOCKER SUMMARY"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo
  echo "validation_status=FAIL"
  echo "failure_class=missing_runtime_trigger_endpoints"
  echo "dashboard_url_used=http://127.0.0.1:8080/dashboard"
  echo "attempted_endpoint_1=/api/tasks/test-success"
  echo "attempted_endpoint_2=/api/tasks/test-failure"
  echo "endpoint_result=Cannot POST"
  echo
  echo "next_step=inspect real local task/event trigger routes before any further runtime validation"
} | tee "$SUMMARY"

{
  echo "PHASE 62B — LIVE VALIDATION BLOCKER ROUTE INSPECTION"
  echo "generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo
  echo "== server routes likely relevant =="
  grep -RIn "app\\.\(get\\|post\\|put\\|delete\\).*api\\|router\\.\(get\\|post\\|put\\|delete\\).*api\\|task\\.completed\\|task\\.failed\\|task-events\\|delegate-task\\|seed task\\|seed_task\\|test-success\\|test-failure" \
    server.mjs server public/js scripts 2>/dev/null || true
  echo
  echo "== api task route candidates =="
  grep -RIn "/api/tasks\\|/api/task\\|delegate-task\\|task-events\\|seed" \
    server.mjs server public/js scripts 2>/dev/null || true
  echo
  echo "== task event emit clues =="
  grep -RIn "task\\.completed\\|task\\.failed\\|task\\.created\\|broadcast.*task\\|mb.task.event" \
    server.mjs server public/js scripts 2>/dev/null || true
} | tee "$FULL"

echo "Summary written to $SUMMARY"
echo "Full route inspection written to $FULL"
