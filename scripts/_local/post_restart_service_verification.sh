#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/post_restart_service_verification_${STAMP}.txt"

{
  echo "POST-RESTART SERVICE VERIFICATION"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== DOCKER STATUS ==="
  docker ps 2>&1 || echo "Docker not running"
  echo

  echo "=== PM2 STATUS ==="
  pm2 list 2>&1 || echo "PM2 not running"
  echo

  echo "=== CLOUDFARED PROCESSES ==="
  ps aux | grep cloudflared | grep -v grep || echo "No cloudflared processes found"
  echo

  echo "=== PORT CHECKS ==="
  lsof -nP -iTCP:3000 -sTCP:LISTEN || echo "Port 3000 not listening"
  lsof -nP -iTCP:8080 -sTCP:LISTEN || echo "Port 8080 not listening"
  lsof -nP -iTCP:5432 -sTCP:LISTEN || echo "Port 5432 not listening"
  echo

  echo "=== HTTP CHECKS ==="
  curl -I --max-time 5 http://localhost:3000 2>&1 || echo "localhost:3000 unreachable"
  curl -I --max-time 5 http://localhost:8080 2>&1 || echo "localhost:8080 unreachable"
  echo

  echo "=== AGENT LOG TAILS ==="
  [ -f "$HOME/matilda.log" ] && { echo "--- matilda.log ---"; tail -n 20 "$HOME/matilda.log"; } || echo "matilda.log missing"
  [ -f "$HOME/cade.log" ] && { echo "--- cade.log ---"; tail -n 20 "$HOME/cade.log"; } || echo "cade.log missing"
  [ -f "$HOME/effie.log" ] && { echo "--- effie.log ---"; tail -n 20 "$HOME/effie.log"; } || echo "effie.log missing"
  echo

  echo "=== FINAL READ ==="
  echo "If Docker + PM2 + cloudflared + expected ports are present, service posture recovered."
  echo "If any are missing, restart only the missing layer."
  echo
} > "${OUT}"

echo "${OUT}"
