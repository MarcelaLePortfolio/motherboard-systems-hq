#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — REVERT MATILDA STATEFUL UPGRADE"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: Working tree is not clean."
  git status --short
  exit 1
fi

echo
echo "== reverting syntax-breaking upgrade commit =="
git revert --no-edit 1b8bd4ba

echo
echo "== pushing revert =="
git push

echo
echo "== rebuilding runtime =="
docker compose down --remove-orphans
docker compose up -d --build

echo
echo "== waiting for health endpoint =="
MAX_ATTEMPTS=30
SLEEP_SECONDS=2
ATTEMPT=1

until curl -fsS http://localhost:8080/diagnostics/system-health >/dev/null 2>&1; do
  if [[ $ATTEMPT -gt $MAX_ATTEMPTS ]]; then
    echo
    echo "ERROR: service failed to become ready after revert"
    echo
    echo "== dashboard logs =="
    docker compose logs --tail=150 dashboard || true
    exit 1
  fi
  echo "waiting... ($ATTEMPT/$MAX_ATTEMPTS)"
  sleep $SLEEP_SECONDS
  ATTEMPT=$((ATTEMPT+1))
done

echo
echo "== POST /api/chat =="
curl -i -s -X POST http://localhost:8080/api/chat \
  -H 'Content-Type: application/json' \
  --data '{"message":"Post-revert sanity check","agent":"matilda"}' \
  | sed -n '1,120p'

echo
echo "== GET /diagnostics/system-health =="
curl -i -s http://localhost:8080/diagnostics/system-health | sed -n '1,80p'

echo
echo "== docker compose ps =="
docker compose ps

echo
echo "────────────────────────────────"
echo "PHASE 487 — REVERT COMPLETE"
echo "────────────────────────────────"
