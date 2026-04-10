#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase469_0_fresh_tasks_route_verification_after_schema_alignment.txt"
START_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

{
  echo "PHASE 469.0 — FRESH TASKS ROUTE VERIFICATION AFTER SCHEMA ALIGNMENT"
  echo "=================================================================="
  echo
  echo "START_TS: $START_TS"
  echo

  echo "STEP 1 — Restart dashboard for clean post-alignment verification"
  docker compose restart dashboard 2>&1 || true
  echo
  sleep 5
  echo "Waited 5 seconds"
  echo

  echo "STEP 2 — Fresh /api/tasks probe"
  echo "--- GET /api/tasks ---"
  curl -i --max-time 5 http://localhost:3000/api/tasks 2>&1 || true
  echo

  echo "STEP 3 — Fresh /dashboard.html probe"
  echo "--- GET /dashboard.html ---"
  curl -i --max-time 5 http://localhost:3000/dashboard.html 2>&1 || true
  echo

  echo "STEP 4 — Fresh /bundle.js probe"
  echo "--- GET /bundle.js ---"
  curl -i --max-time 5 http://localhost:3000/bundle.js 2>&1 || true
  echo

  echo "STEP 5 — Targeted fresh log read"
  docker compose logs --tail=120 dashboard 2>&1 || true
  echo

  echo "STEP 6 — Fresh failure classification"
  LOGS="$(docker compose logs --tail=120 dashboard 2>&1 || true)"

  if echo "$LOGS" | rg -q 'column "title" does not exist'; then
    echo "CLASSIFICATION: TITLE_ERROR_STILL_PRESENT"
  elif echo "$LOGS" | rg -q 'GET /api/tasks' && echo "$LOGS" | rg -q '\[HTTP\] GET /dashboard.html' && ! echo "$LOGS" | rg -q 'ERROR|Error|Unhandled|exception|Cannot GET|not found'; then
    echo "CLASSIFICATION: SERVER_PATH_NOW_CLEAN_BROWSER_CONSOLE_NEXT"
  else
    echo "CLASSIFICATION: FRESH_SERVER_REVIEW_REQUIRED"
  fi
} > "$OUT"

echo "Wrote $OUT"
