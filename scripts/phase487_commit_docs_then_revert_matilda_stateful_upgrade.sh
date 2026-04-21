#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — COMMIT DOCS THEN REVERT MATILDA STATEFUL UPGRADE"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

echo
echo "== current status =="
git status --short

echo
echo "== staging generated verification docs if present =="
DOCS=()
[[ -f docs/phase487_verify_matilda_stateful_live.md ]] && DOCS+=("docs/phase487_verify_matilda_stateful_live.md")
[[ -f docs/phase487_verify_matilda_stateful_live_bounded.md ]] && DOCS+=("docs/phase487_verify_matilda_stateful_live_bounded.md")

if [[ ${#DOCS[@]} -gt 0 ]]; then
  git add "${DOCS[@]}"
  if ! git diff --cached --quiet; then
    git commit -m "PHASE 487: record failed Matilda stateful verification outputs before controlled revert"
    git push
  fi
fi

echo
echo "== status before revert =="
git status --short

if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: Working tree still not clean after doc commit step."
  exit 1
fi

echo
echo "== reverting syntax-breaking upgrade commit =="
git revert --no-edit 1b8bd4ba
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
echo "PHASE 487 — DOC COMMIT + REVERT COMPLETE"
echo "────────────────────────────────"
