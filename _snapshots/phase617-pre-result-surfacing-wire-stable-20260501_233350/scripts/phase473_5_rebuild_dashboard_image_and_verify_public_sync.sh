#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase473_5_rebuild_dashboard_image_and_verify_public_sync.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

{
  echo "PHASE 473.5 — REBUILD DASHBOARD IMAGE AND VERIFY PUBLIC SYNC"
  echo "============================================================"
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Rebuild dashboard image from current working tree"
  docker compose build --no-cache dashboard 2>&1 || true
  echo

  echo "STEP 2 — Recreate dashboard container"
  docker compose up -d --force-recreate dashboard 2>&1 || true
  echo

  echo "STEP 3 — Wait for host port 8080 readiness"
  READY=0
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    if curl -s --max-time 2 http://localhost:8080/dashboard.html >/dev/null 2>&1; then
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

  echo "STEP 4 — Verify container now sees updated public files"
  echo "--- CONTAINER /app/public/minimal_probe.html ---"
  docker compose exec -T dashboard sh -lc 'ls -l /app/public/minimal_probe.html && sha1sum /app/public/minimal_probe.html' 2>&1 || true
  echo
  echo "--- CONTAINER /app/public/dashboard.html ---"
  docker compose exec -T dashboard sh -lc 'wc -l /app/public/dashboard.html && sha1sum /app/public/dashboard.html' 2>&1 || true
  echo

  echo "STEP 5 — Host vs served probe"
  echo "--- HOST minimal_probe checksum ---"
  shasum public/minimal_probe.html 2>&1 || true
  echo
  echo "--- GET /minimal_probe.html ---"
  curl -i --max-time 5 http://localhost:8080/minimal_probe.html 2>&1 || true
  echo
  echo "--- GET /dashboard.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo

  echo "STEP 6 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 7 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  elif docker compose exec -T dashboard sh -lc 'test -f /app/public/minimal_probe.html' && curl -s --max-time 5 http://localhost:8080/minimal_probe.html >/tmp/phase4735_minimal_probe_served.html 2>/dev/null && rg -q 'Minimal Probe Page' /tmp/phase4735_minimal_probe_served.html; then
    echo "CLASSIFICATION: CONTAINER_SYNC_FIXED_AND_MINIMAL_PROBE_SERVED"
  else
    echo "CLASSIFICATION: CONTAINER_SYNC_STILL_BROKEN_OR_ROUTE_NOT_SERVING_NEW_FILE"
  fi
  echo

  echo "DECISION TARGET"
  echo "- If sync is fixed, open http://localhost:8080/minimal_probe.html and report:"
  echo "  • MINIMAL_PROBE_STABLE"
  echo "  • MINIMAL_PROBE_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
  echo "- If not fixed, next step is route/static serving precedence, not browser debugging."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
