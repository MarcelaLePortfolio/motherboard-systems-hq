#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase470_8_remaining_live_dashboard_surfaces.txt"
HTML="public/dashboard.html"
BUNDLE="public/bundle.js"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

{
  echo "PHASE 470.8 — PROBE REMAINING LIVE DASHBOARD SURFACES"
  echo "====================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Dashboard script tags still present"
  rg -n "<script src=|phase457_restore_task_panels|phase61_tabs_workspace|phase61_recent_history_wire|phase60_live_clock|phase457_neutralize_legacy_observational_consumers|bundle.js" "$HTML" || true
  echo

  echo "STEP 2 — High-signal live behaviors in dashboard HTML"
  rg -n "fetch\\(|EventSource|setInterval|setTimeout|requestAnimationFrame|operatorGuidance|api/tasks|api/runs|events/ops|events/task-events|api/operator-guidance" "$HTML" || true
  echo

  echo "STEP 3 — High-signal live behaviors in bundle"
  rg -n "fetch\\(|new EventSource|setInterval\\(|setTimeout\\(|requestAnimationFrame|/events/ops|/events/task-events|/api/tasks|/api/runs|/api/chat|/api/delegate-task|/api/operator-guidance" "$BUNDLE" || true
  echo

  echo "STEP 4 — Count live primitives in bundle"
  echo "EventSource count: $(rg -F -o 'new EventSource' "$BUNDLE" | wc -l | tr -d ' ')"
  echo "setInterval count: $(rg -F -o 'setInterval(' "$BUNDLE" | wc -l | tr -d ' ')"
  echo "setTimeout count: $(rg -F -o 'setTimeout(' "$BUNDLE" | wc -l | tr -d ' ')"
  echo "fetch count: $(rg -F -o 'fetch(' "$BUNDLE" | wc -l | tr -d ' ')"
  echo

  echo "STEP 5 — Fresh host probes"
  echo "--- GET /dashboard.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo
  echo "--- GET /bundle.js ---"
  curl -I --max-time 5 http://localhost:8080/bundle.js 2>&1 || true
  echo
  echo "--- GET /api/tasks ---"
  curl -I --max-time 5 http://localhost:8080/api/tasks 2>&1 || true
  echo
  echo "--- GET /api/runs?limit=20 ---"
  curl -I --max-time 5 "http://localhost:8080/api/runs?limit=20" 2>&1 || true
  echo
  echo "--- GET /events/ops ---"
  curl -I --max-time 5 http://localhost:8080/events/ops 2>&1 || true
  echo
  echo "--- GET /events/task-events ---"
  curl -I --max-time 5 http://localhost:8080/events/task-events 2>&1 || true
  echo

  echo "STEP 6 — Fresh dashboard logs after probe window"
  sleep 6
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 7 — Request concentration summary"
  LOGS="$(docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true)"
  echo "GET /events/ops count: $(printf '%s\n' "$LOGS" | rg -o '\[HTTP\] GET /events/ops' | wc -l | tr -d ' ')"
  echo "GET /events/task-events count: $(printf '%s\n' "$LOGS" | rg -o '\[HTTP\] GET /events/task-events' | wc -l | tr -d ' ')"
  echo "GET /api/tasks count: $(printf '%s\n' "$LOGS" | rg -o '\[HTTP\] GET /api/tasks' | wc -l | tr -d ' ')"
  echo "GET /api/runs count: $(printf '%s\n' "$LOGS" | rg -o '\[HTTP\] GET /api/runs' | wc -l | tr -d ' ')"
  echo

  echo "STEP 8 — Classification"
  OPS_COUNT="$(printf '%s\n' "$LOGS" | rg -o '\[HTTP\] GET /events/ops' | wc -l | tr -d ' ')"
  TASK_COUNT="$(printf '%s\n' "$LOGS" | rg -o '\[HTTP\] GET /events/task-events' | wc -l | tr -d ' ')"
  RUNS_COUNT="$(printf '%s\n' "$LOGS" | rg -o '\[HTTP\] GET /api/runs' | wc -l | tr -d ' ')"
  TASKS_COUNT="$(printf '%s\n' "$LOGS" | rg -o '\[HTTP\] GET /api/tasks' | wc -l | tr -d ' ')"

  if [ "${OPS_COUNT:-0}" -gt 3 ]; then
    echo "CLASSIFICATION: OPS_STREAM_ACTIVITY_HEAVY"
  elif [ "${TASK_COUNT:-0}" -gt 3 ]; then
    echo "CLASSIFICATION: TASK_EVENTS_ACTIVITY_HEAVY"
  elif [ "${RUNS_COUNT:-0}" -gt 3 ]; then
    echo "CLASSIFICATION: RUNS_POLLING_ACTIVITY_HEAVY"
  elif [ "${TASKS_COUNT:-0}" -gt 3 ]; then
    echo "CLASSIFICATION: TASKS_POLLING_ACTIVITY_HEAVY"
  else
    echo "CLASSIFICATION: MANUAL_BROWSER_STABILITY_REVIEW_WITH_REMAINING_LIVE_SURFACES_MAPPED"
  fi

  echo
  echo "DECISION TARGET"
  echo "- Next mutation must target only the heaviest remaining live surface."
  echo "- Do not stack multiple neutralizations in one step."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
