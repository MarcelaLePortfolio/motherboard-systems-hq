#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase470_5_ui_unresponsive_over_time.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

{
  echo "PHASE 470.5 — DIAGNOSE UI UNRESPONSIVE OVER TIME"
  echo "==============================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Confirm dashboard/container state"
  docker compose ps 2>&1 || true
  echo

  echo "STEP 2 — Probe key endpoints on host port 8080"
  echo "--- GET /dashboard.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo
  echo "--- GET /bundle.js ---"
  curl -I --max-time 5 http://localhost:8080/bundle.js 2>&1 || true
  echo
  echo "--- GET /api/tasks ---"
  curl -I --max-time 5 http://localhost:8080/api/tasks 2>&1 || true
  echo
  echo "--- GET /api/operator-guidance ---"
  curl -I --max-time 5 http://localhost:8080/api/operator-guidance 2>&1 || true
  echo

  echo "STEP 3 — Search front-end bundle/source for likely runaway causes"
  rg -n "setInterval|setTimeout|requestAnimationFrame|new EventSource|addEventListener\\(|window\\.addEventListener\\(|DOMContentLoaded|__PHASE16_SSE_OWNER_STARTED|__opsGlobalsBridgeInitialized|__PHASE22_TASK_UI_BOUND|__PHASE63_SHARED_TASK_EVENTS_METRICS__|__broadcastVisualizationInited" public src 2>&1 || true
  echo

  echo "STEP 4 — Count repeated EventSource / timer patterns in bundle"
  echo "EventSource count:"
  rg -o "new EventSource" public/bundle.js 2>/dev/null | wc -l | tr -d ' '
  echo "setInterval count:"
  rg -o "setInterval\\(" public/bundle.js 2>/dev/null | wc -l | tr -d ' '
  echo "DOMContentLoaded count:"
  rg -o "DOMContentLoaded" public/bundle.js 2>/dev/null | wc -l | tr -d ' '
  echo

  echo "STEP 5 — Fresh dashboard logs during short observation window"
  sleep 8
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 6 — SSE / polling / repeated-request signals in fresh logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 | rg -n "\\[HTTP\\] GET /events/ops|\\[HTTP\\] GET /events/task-events|\\[HTTP\\] GET /api/tasks|\\[HTTP\\] GET /api/operator-guidance|poll|loop|interval|EventSource" || true
  echo

  echo "STEP 7 — Classification"
  LOGS="$(docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true)"
  if echo "$LOGS" | rg -q 'column "title" does not exist'; then
    echo "CLASSIFICATION: BACKEND_REGRESSION"
  elif echo "$LOGS" | rg -q 'ERROR|Error|Unhandled|exception|Cannot GET|not found'; then
    echo "CLASSIFICATION: SERVER_RUNTIME_ERROR"
  elif echo "$LOGS" | rg -q '\[HTTP\] GET /events/ops' && [ "$(echo "$LOGS" | rg -o '\[HTTP\] GET /events/ops' | wc -l | tr -d ' ')" -gt 3 ]; then
    echo "CLASSIFICATION: POSSIBLE_SSE_OR_RECONNECT_STORM"
  elif echo "$LOGS" | rg -q '\[HTTP\] GET /api/tasks' && [ "$(echo "$LOGS" | rg -o '\[HTTP\] GET /api/tasks' | wc -l | tr -d ' ')" -gt 3 ]; then
    echo "CLASSIFICATION: POSSIBLE_POLLING_STORM"
  else
    echo "CLASSIFICATION: LIKELY_BROWSER_RUNTIME_OR_DEVTOOLS_CONTEXT_ISSUE"
  fi
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
