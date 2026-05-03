#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase470_4_reconfirm_white_screen_state.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

# Clean up accidental stray file if it exists
rm -f "./...."

{
  echo "PHASE 470.4 — RECONFIRM WHITE SCREEN STATE"
  echo "========================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Compose state"
  docker compose ps 2>&1 || true
  echo

  echo "STEP 2 — Host port 8080 probe"
  echo "--- GET /dashboard.html ---"
  curl -i --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo
  echo "--- GET /bundle.js ---"
  curl -i --max-time 5 http://localhost:8080/bundle.js 2>&1 || true
  echo
  echo "--- GET /api/tasks ---"
  curl -i --max-time 5 http://localhost:8080/api/tasks 2>&1 || true
  echo

  echo "STEP 3 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 4 — Classification"
  LOGS="$(docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true)"
  if ! curl -s --max-time 5 http://localhost:8080/dashboard.html >/dev/null 2>&1; then
    echo "CLASSIFICATION: DASHBOARD_HTTP_DOWN"
  elif echo "$LOGS" | rg -q 'column "title" does not exist'; then
    echo "CLASSIFICATION: TASKS_ROUTE_REGRESSION"
  elif echo "$LOGS" | rg -q 'ERROR|Error|Unhandled|exception|Cannot GET|not found'; then
    echo "CLASSIFICATION: SERVER_SIDE_RUNTIME_ERROR"
  else
    echo "CLASSIFICATION: SERVER_PATH_STILL_CLEAN_BROWSER_FAILURE_LIKELY"
  fi
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
