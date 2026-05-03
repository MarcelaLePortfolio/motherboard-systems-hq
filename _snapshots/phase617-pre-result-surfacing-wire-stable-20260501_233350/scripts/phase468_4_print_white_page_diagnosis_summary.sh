#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SRC="docs/phase468_3_white_page_refresh_diagnosis.txt"
OUT="docs/phase468_4_white_page_diagnosis_summary.txt"

mkdir -p docs

{
  echo "PHASE 468.4 — WHITE PAGE DIAGNOSIS SUMMARY"
  echo "=========================================="
  echo
  echo "SOURCE: $SRC"
  echo

  echo "STEP 1 — Root/dashboard HTTP lines"
  rg -n "GET / ---|GET /dashboard ---|HTTP/|Content-Type:|Cannot GET|Not Found|bundle.js|dashboard.html" "$SRC" || true
  echo

  echo "STEP 2 — Dashboard container health lines"
  rg -n "dashboard|Up |Exit|unhealthy|healthy|Restarting|starting" "$SRC" || true
  echo

  echo "STEP 3 — High-signal error lines"
  rg -n "Error|ERROR|Cannot|failed|exception|Unhandled|not found|ENOENT|EACCES|module|MIME|Unexpected token" "$SRC" || true
  echo

  echo "STEP 4 — Quick classification"
  if rg -q "Cannot GET /dashboard|404 Not Found" "$SRC"; then
    echo "CLASSIFICATION: DASHBOARD_ROUTE_OR_ENTRYPOINT_FAILURE"
  elif rg -q "/bundle.js" "$SRC" && rg -q "404 Not Found|Cannot GET /bundle.js" "$SRC"; then
    echo "CLASSIFICATION: STATIC_ASSET_SERVING_FAILURE"
  elif rg -q "unhealthy|Restarting|Exit" "$SRC"; then
    echo "CLASSIFICATION: DASHBOARD_SERVICE_HEALTH_FAILURE"
  elif rg -q "Error|ERROR|Unexpected token|module|ENOENT|not found" "$SRC"; then
    echo "CLASSIFICATION: FRONTEND_OR_SERVER_RUNTIME_FAILURE"
  else
    echo "CLASSIFICATION: MANUAL_REVIEW_REQUIRED"
  fi
  echo

  echo "STEP 5 — Tail of source for immediate review"
  tail -n 120 "$SRC" 2>/dev/null || true
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
