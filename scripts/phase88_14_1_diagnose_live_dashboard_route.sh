#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:3000}"

OUT_EVIDENCE="PHASE88_14_1_LIVE_DASHBOARD_ROUTE_DIAGNOSIS.txt"
OUT_HEALTH_HEADERS="PHASE88_14_1_health_headers.txt"
OUT_HEALTH_BODY="PHASE88_14_1_health_body.json"
OUT_DASHBOARD_HEADERS="PHASE88_14_1_dashboard_headers.txt"
OUT_DASHBOARD_BODY="PHASE88_14_1_dashboard_body.txt"
OUT_ROOT_HEADERS="PHASE88_14_1_root_headers.txt"
OUT_ROOT_BODY="PHASE88_14_1_root_body.txt"
OUT_PUBLIC_HEADERS="PHASE88_14_1_public_dashboard_headers.txt"
OUT_PUBLIC_BODY="PHASE88_14_1_public_dashboard_body.html"
BOOT_LOG="PHASE88_14_SERVER_BOOT.log"
PID_FILE=".phase88_14_server.pid"

curl -sS -D "$OUT_HEALTH_HEADERS" -o "$OUT_HEALTH_BODY" "$BASE_URL/diagnostics/system-health" || true
curl -sS -D "$OUT_DASHBOARD_HEADERS" -o "$OUT_DASHBOARD_BODY" "$BASE_URL/dashboard" || true
curl -sS -D "$OUT_ROOT_HEADERS" -o "$OUT_ROOT_BODY" "$BASE_URL/" || true
curl -sS -D "$OUT_PUBLIC_HEADERS" -o "$OUT_PUBLIC_BODY" "$BASE_URL/public/dashboard.html" || true

{
  echo "PHASE 88.14.1 LIVE DASHBOARD ROUTE DIAGNOSIS"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Base URL: $BASE_URL"
  echo "────────────────────────────────"

  if [[ -f "$PID_FILE" ]]; then
    echo "PID FILE: $(cat "$PID_FILE")"
  fi

  if [[ -f "$BOOT_LOG" ]]; then
    echo "BOOT LOG TAIL:"
    tail -n 80 "$BOOT_LOG"
    echo "────────────────────────────────"
  fi

  echo "HEALTH HEADERS:"
  cat "$OUT_HEALTH_HEADERS"
  echo "HEALTH BODY:"
  cat "$OUT_HEALTH_BODY"
  echo
  echo "────────────────────────────────"

  echo "DASHBOARD HEADERS:"
  cat "$OUT_DASHBOARD_HEADERS"
  echo "DASHBOARD BODY:"
  cat "$OUT_DASHBOARD_BODY"
  echo
  echo "────────────────────────────────"

  echo "ROOT HEADERS:"
  cat "$OUT_ROOT_HEADERS"
  echo "ROOT BODY:"
  cat "$OUT_ROOT_BODY"
  echo
  echo "────────────────────────────────"

  echo "PUBLIC DASHBOARD HEADERS:"
  cat "$OUT_PUBLIC_HEADERS"
  echo "PUBLIC DASHBOARD BODY HITS:"
  rg -n 'Operator Console|System Health Diagnostics|system-health-content|bundle.js' "$OUT_PUBLIC_BODY" || true
  echo "────────────────────────────────"
} | tee "$OUT_EVIDENCE"
