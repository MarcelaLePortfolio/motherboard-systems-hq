#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_rebuild_dashboard_for_confidence_fix_${STAMP}.txt"

{
  echo "PHASE 487 — REBUILD DASHBOARD FOR CONFIDENCE FIX"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== SOURCE CHECK ==="
  rg -n -C 3 "insufficient|limited|confidence" src/cognition/operatorGuidanceConfidence.ts src/cognition/operatorGuidanceMapping.ts || true
  echo

  echo "=== REPO-WIDE REMAINING INSUFFICIENT REFERENCES ==="
  rg -n -C 2 "Confidence: insufficient|confidence.*insufficient|insufficient" app src ui lib pages . \
    --glob '!.git' \
    --glob '!node_modules' \
    --glob '!.next' \
    --glob '!dist' \
    --glob '!coverage' || true
  echo

  echo "=== DOCKER COMPOSE REBUILD ==="
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    docker compose build --no-cache 2>&1 || docker-compose build --no-cache 2>&1 || true
    docker compose up -d 2>&1 || docker-compose up -d 2>&1 || true
  else
    echo "Docker unavailable; skipping compose rebuild"
  fi
  echo

  echo "=== PM2 RESTART ==="
  if command -v pm2 >/dev/null 2>&1; then
    pm2 restart all 2>&1 || true
  else
    echo "PM2 unavailable; skipping restart"
  fi
  echo

  echo "=== HTTP CHECK ==="
  curl -I --max-time 5 http://localhost:3000 2>&1 || echo "localhost:3000 unreachable"
  curl -I --max-time 5 http://localhost:8080 2>&1 || echo "localhost:8080 unreachable"
  echo

  echo "=== FINAL READ ==="
  echo "If dashboard still shows Confidence: insufficient after rebuild/restart, the remaining source is outside the already-patched mapping files."
  echo
} > "${OUT}"

echo "${OUT}"
