#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_rebuild_dashboard_container.txt"

{
  echo "PHASE 456 — REBUILD DASHBOARD CONTAINER (FIX STALE BUNDLE)"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== STOP DASHBOARD ==="
  docker compose stop dashboard
  echo

  echo "=== REMOVE DASHBOARD CONTAINER ==="
  docker compose rm -f dashboard
  echo

  echo "=== REBUILD IMAGE (NO CACHE) ==="
  docker compose build --no-cache dashboard
  echo

  echo "=== START DASHBOARD ==="
  docker compose up -d dashboard
  echo

  echo "=== WAIT FOR HEALTH ==="
  sleep 6
  docker compose ps
  echo

  echo "=== VERIFY JS SERVED (FIRST 40 LINES) ==="
  curl -fsS http://localhost:8080/js/operatorGuidance.sse.js | sed -n '1,40p'
  echo

  echo "=== EXPECTED ==="
  echo "You should now see PHASE456_MINIMAL_GUIDANCE_EMITTER in the file"
  echo

} | tee "$OUT"
