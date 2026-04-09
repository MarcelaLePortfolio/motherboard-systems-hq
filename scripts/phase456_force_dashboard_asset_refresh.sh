#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_force_dashboard_asset_refresh.txt"

{
  echo "PHASE 456 — FORCE DASHBOARD ASSET REFRESH"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== HARD RESTART DASHBOARD CONTAINER ==="
  docker compose restart dashboard
  echo

  echo "=== WAIT FOR HEALTH ==="
  sleep 5
  docker compose ps
  echo

  echo "=== VERIFY JS SERVED (FIRST 40 LINES) ==="
  curl -fsS http://localhost:8080/js/operatorGuidance.sse.js | sed -n '1,40p'
  echo

  echo "=== CACHE BYPASS CHECK ==="
  curl -fsS "http://localhost:8080/js/operatorGuidance.sse.js?v=$(date +%s)" | sed -n '1,40p'
  echo

  echo "=== INSTRUCTION ==="
  echo "Hard refresh browser: Cmd+Shift+R"
  echo

} | tee "$OUT"
