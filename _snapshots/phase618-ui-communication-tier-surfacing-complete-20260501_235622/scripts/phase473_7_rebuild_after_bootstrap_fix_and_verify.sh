#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase473_7_rebuild_after_bootstrap_fix_and_verify.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

{
  echo "PHASE 473.7 — REBUILD AFTER BOOTSTRAP FIX AND VERIFY"
  echo "===================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Rebuild dashboard image"
  docker compose build dashboard 2>&1 || true
  echo

  echo "STEP 2 — Recreate dashboard container"
  docker compose up -d --force-recreate dashboard 2>&1 || true
  echo

  echo "STEP 3 — Wait for host port 8080 readiness"
  READY=0
  for i in {1..20}; do
    if curl -s --max-time 2 http://localhost:8080 >/dev/null 2>&1; then
      echo "READY_ON_8080 (attempt $i)"
      READY=1
      break
    else
      echo "waiting_for_8080 (attempt $i)"
      sleep 1
    fi
  done
  if [ "$READY" -ne 1 ]; then
    echo "HOST_8080_NOT_READY_AFTER_WAIT"
  fi
  echo

  echo "STEP 4 — Verify container public files"
  echo "--- CONTAINER minimal_probe ---"
  docker compose exec -T dashboard sh -lc 'ls -l /app/public/minimal_probe.html && sha1sum /app/public/minimal_probe.html' 2>&1 || true
  echo
  echo "--- CONTAINER dashboard ---"
  docker compose exec -T dashboard sh -lc 'wc -l /app/public/dashboard.html && sha1sum /app/public/dashboard.html' 2>&1 || true
  echo

  echo "STEP 5 — Probe endpoints"
  echo "--- GET /minimal_probe.html ---"
  curl -i --max-time 5 http://localhost:8080/minimal_probe.html 2>&1 || true
  echo
  echo "--- GET /dashboard.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo

  echo "STEP 6 — Logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 7 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  elif curl -s --max-time 5 http://localhost:8080/minimal_probe.html | grep -q "Minimal Probe Page"; then
    echo "CLASSIFICATION: SERVER_RUNNING_AND_PROBE_OK"
  else
    echo "CLASSIFICATION: SERVER_RUNNING_BUT_PROBE_NOT_SERVED"
  fi
  echo

} > "$OUT"

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"
