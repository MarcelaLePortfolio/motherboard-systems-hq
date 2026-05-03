#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase469_4_verify_host_port_8080_and_dashboard_refresh.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

{
  echo "PHASE 469.4 — VERIFY HOST PORT 8080 + DASHBOARD REFRESH"
  echo "======================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Confirm compose port mapping"
  docker compose ps 2>&1 || true
  echo

  echo "STEP 2 — Wait for HOST port 8080 readiness"
  READY=0
  for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
    if curl -s --max-time 2 http://localhost:8080/ >/dev/null 2>&1; then
      READY=1
      echo "READY_ON_8080 attempt=$i"
      break
    fi
    sleep 2
  done
  if [ "$READY" -ne 1 ]; then
    echo "HOST_8080_NOT_READY_AFTER_WAIT"
  fi
  echo

  echo "STEP 3 — Fresh probes on correct HOST port"
  echo "--- GET http://localhost:8080/dashboard.html ---"
  curl -i --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo
  echo "--- GET http://localhost:8080/bundle.js ---"
  curl -i --max-time 5 http://localhost:8080/bundle.js 2>&1 || true
  echo
  echo "--- GET http://localhost:8080/api/tasks ---"
  curl -i --max-time 5 http://localhost:8080/api/tasks 2>&1 || true
  echo

  echo "STEP 4 — Fresh dashboard logs since probe start"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 5 — Final classification"
  LOGS="$(docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true)"

  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_PORT_8080_NOT_READY"
  elif echo "$LOGS" | rg -q 'column "title" does not exist'; then
    echo "CLASSIFICATION: TITLE_ERROR_CONFIRMED_ON_FRESH_8080_PROBE"
  elif curl -s --max-time 5 http://localhost:8080/dashboard.html >/dev/null 2>&1 \
    && curl -s --max-time 5 http://localhost:8080/bundle.js >/dev/null 2>&1; then
    echo "CLASSIFICATION: SERVER_PATH_CLEAN_ON_CORRECT_HOST_PORT"
  else
    echo "CLASSIFICATION: FRESH_8080_MANUAL_REVIEW_REQUIRED"
  fi
  echo

  echo "STEP 6 — Browser next action"
  echo "- Open: http://localhost:8080/dashboard.html"
  echo "- Hard refresh once."
  echo "- If still white, next evidence should be browser console errors, not localhost:3000 curl output."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
