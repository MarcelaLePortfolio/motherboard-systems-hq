#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase469_2_verify_with_fresh_logs_only.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

{
  echo "PHASE 469.2 — VERIFY WITH FRESH LOGS ONLY"
  echo "========================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Restart dashboard"
  docker compose restart dashboard 2>&1 || true
  echo

  echo "STEP 2 — Wait for port 3000 readiness"
  READY=0
  for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
    if curl -s --max-time 2 http://localhost:3000/ >/dev/null 2>&1; then
      READY=1
      echo "READY on attempt $i"
      break
    fi
    sleep 2
  done
  if [ "$READY" -ne 1 ]; then
    echo "SERVER_NOT_READY_AFTER_WAIT"
  fi
  echo

  echo "STEP 3 — Fresh probes after readiness"
  echo "--- GET /api/tasks ---"
  curl -i --max-time 5 http://localhost:3000/api/tasks 2>&1 || true
  echo
  echo "--- GET /dashboard.html ---"
  curl -i --max-time 5 http://localhost:3000/dashboard.html 2>&1 || true
  echo
  echo "--- GET /bundle.js ---"
  curl -i --max-time 5 http://localhost:3000/bundle.js 2>&1 || true
  echo

  echo "STEP 4 — Fresh logs only (since restart window)"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 5 — Fresh classification"
  FRESH_LOGS="$(docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true)"

  if echo "$FRESH_LOGS" | rg -q 'column "title" does not exist'; then
    echo "CLASSIFICATION: TITLE_ERROR_CONFIRMED_FRESH"
  elif echo "$FRESH_LOGS" | rg -q '\[HTTP\] GET /api/tasks' && ! echo "$FRESH_LOGS" | rg -q 'ERROR|Error|Unhandled|exception|Cannot GET|not found'; then
    echo "CLASSIFICATION: TASKS_ROUTE_CLEAN_FRESH"
  elif [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: SERVER_BOOT_READINESS_PROBLEM"
  else
    echo "CLASSIFICATION: FRESH_MANUAL_REVIEW_REQUIRED"
  fi
} > "$OUT"

echo "Wrote $OUT"
