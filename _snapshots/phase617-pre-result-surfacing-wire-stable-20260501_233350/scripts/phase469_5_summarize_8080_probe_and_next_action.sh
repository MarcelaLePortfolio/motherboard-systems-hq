#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SRC="docs/phase469_4_verify_host_port_8080_and_dashboard_refresh.txt"
OUT="docs/phase469_5_8080_probe_summary.txt"

mkdir -p docs

{
  echo "PHASE 469.5 — 8080 PROBE SUMMARY"
  echo "================================"
  echo
  echo "SOURCE: $SRC"
  echo

  echo "STEP 1 — Key HTTP result lines"
  rg -n "READY_ON_8080|HOST_8080_NOT_READY|GET http://localhost:8080/dashboard.html|GET http://localhost:8080/bundle.js|GET http://localhost:8080/api/tasks|HTTP/1.1|HTTP/2|Content-Type:|Cannot GET|Not Found|column \"title\" does not exist|CLASSIFICATION:" "$SRC" || true
  echo

  echo "STEP 2 — Fresh error-only lines"
  rg -n "ERROR|Error|Unhandled|exception|does not exist|not found|Cannot GET|Unexpected token|ReferenceError|TypeError" "$SRC" || true
  echo

  echo "STEP 3 — Final classification"
  if rg -q "CLASSIFICATION: SERVER_PATH_CLEAN_ON_CORRECT_HOST_PORT" "$SRC"; then
    echo "STATUS: SERVER_PATH_CLEAN_ON_8080"
  elif rg -q "CLASSIFICATION: TITLE_ERROR_CONFIRMED_ON_FRESH_8080_PROBE" "$SRC"; then
    echo "STATUS: TASKS_ROUTE_ERROR_STILL_PRESENT"
  elif rg -q "CLASSIFICATION: HOST_PORT_8080_NOT_READY" "$SRC"; then
    echo "STATUS: HOST_8080_NOT_READY"
  else
    echo "STATUS: NEED_CLASSIFICATION_EXTRACTION"
  fi
  echo

  echo "STEP 4 — Next action"
  echo "- If SERVER_PATH_CLEAN_ON_8080: capture browser console errors next."
  echo "- If TASKS_ROUTE_ERROR_STILL_PRESENT: inspect /api/tasks response body next."
  echo "- If HOST_8080_NOT_READY: stay in boot/readiness corridor."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
