#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — DELEGATION SURFACE VERIFY"
echo "────────────────────────────────"

OUT="docs/phase487_delegation_surface_verify.md"
mkdir -p docs

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

{
  echo "# Phase 487 Delegation Surface Verification"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Runtime posture"
  echo
  echo '```'
  git status --short
  echo
  docker compose ps
  echo '```'
  echo
  echo "## Live endpoint checks"
  echo
  echo '```'
  echo "GET /api/delegate-task"
  curl -i -s http://localhost:8080/api/delegate-task | sed -n '1,40p' || true
  echo
  echo "POST /api/delegate-task"
  curl -i -s -X POST http://localhost:8080/api/delegate-task \
    -H 'Content-Type: application/json' \
    --data '{"prompt":"Phase 487 delegation surface verification request","message":"Phase 487 delegation surface verification request","text":"Phase 487 delegation surface verification request","task":"Phase 487 delegation surface verification request"}' \
    | sed -n '1,120p' || true
  echo '```'
  echo
  echo "## Recent dashboard logs"
  echo
  echo '```'
  docker compose logs --tail=120 dashboard || true
  echo '```'
  echo
  echo "## Determination template"
  echo
  echo "- If POST returns 2xx with JSON, delegation surface is live."
  echo "- If POST returns 4xx/5xx, capture the exact response/error and stop before patching."
  echo "- GET may still 404 if the route is POST-only; that is not itself a defect."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,240p' "$OUT"
