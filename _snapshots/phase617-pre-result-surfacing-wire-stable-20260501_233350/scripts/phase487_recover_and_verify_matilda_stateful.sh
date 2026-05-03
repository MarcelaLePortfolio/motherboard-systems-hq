#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — RECOVER + VERIFY MATILDA STATE-AWARE (FINAL HARDENED)"
echo "────────────────────────────────"

echo
echo "== docker compose ps (pre-check) =="
docker compose ps || true

echo
echo "== hard reset (containers, volumes preserved) =="
docker compose down --remove-orphans
docker compose up -d --build

echo
echo "== waiting for service readiness via system-health =="
MAX_ATTEMPTS=40
SLEEP_SECONDS=2
ATTEMPT=1

until curl -fsS http://localhost:8080/diagnostics/system-health >/dev/null 2>&1; do
  if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
    echo
    echo "ERROR: service failed to become ready"
    echo
    echo "== dashboard logs (diagnostic dump) =="
    docker compose logs --tail=150 dashboard || true
    exit 1
  fi
  echo "waiting... ($ATTEMPT/$MAX_ATTEMPTS)"
  sleep $SLEEP_SECONDS
  ATTEMPT=$((ATTEMPT+1))
done

echo "Service is UP and responding"

echo
echo "== POST /api/chat (state-aware verification) =="
curl -s -X POST http://localhost:8080/api/chat \
  -H 'Content-Type: application/json' \
  --data '{"message":"Status check after cognition upgrade"}' \
  | sed -n '1,200p'

echo
echo "== GET /diagnostics/system-health =="
curl -s http://localhost:8080/diagnostics/system-health | sed -n '1,120p'

echo
echo "== GET /api/tasks =="
curl -s http://localhost:8080/api/tasks | sed -n '1,120p'

echo
echo "== recent dashboard logs =="
docker compose logs --tail=120 dashboard || true

echo
echo "────────────────────────────────"
echo "PHASE 487 — RECOVERY + VERIFICATION COMPLETE"
echo "────────────────────────────────"
