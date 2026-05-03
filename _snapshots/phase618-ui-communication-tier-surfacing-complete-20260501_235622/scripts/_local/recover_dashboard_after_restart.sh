#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/dashboard_recovery_${STAMP}.txt"

{
  echo "DASHBOARD RECOVERY AFTER RESTART"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== STEP 1: DOCKER DESKTOP STATUS ==="
  if ! docker info >/dev/null 2>&1; then
    echo "Docker daemon unavailable"
    echo "Attempting to launch Docker Desktop..."
    open -a Docker || true

    for i in $(seq 1 60); do
      if docker info >/dev/null 2>&1; then
        echo "Docker daemon ready after ${i}s"
        break
      fi
      sleep 1
    done
  fi

  if docker info >/dev/null 2>&1; then
    echo "Docker daemon is running"
  else
    echo "Docker daemon still unavailable"
  fi
  echo

  echo "=== STEP 2: START/RESTORE LOCAL CONTAINERS ==="
  if [ -f docker-compose.yml ] || [ -f compose.yml ] || [ -f docker-compose.yaml ] || [ -f compose.yaml ]; then
    docker compose up -d 2>&1 || true
  else
    echo "No compose file found at repo root"
  fi
  echo

  echo "=== STEP 3: PM2 STATUS BEFORE RECOVERY ==="
  pm2 list 2>&1 || true
  echo

  echo "=== STEP 4: RESTORE PM2 AGENTS IF LAUNCHERS EXIST ==="
  if [ -f scripts/_local/agent-runtime/launch-cade.ts ]; then
    pm2 describe cade >/dev/null 2>&1 || pm2 start "scripts/_local/agent-runtime/launch-cade.ts" --name cade --interpreter "$(which tsx)" 2>&1 || true
  fi

  if [ -f scripts/_local/agent-runtime/launch-matilda.ts ]; then
    pm2 describe matilda >/dev/null 2>&1 || pm2 start "scripts/_local/agent-runtime/launch-matilda.ts" --name matilda --interpreter "$(which tsx)" 2>&1 || true
  fi

  if [ -f scripts/_local/agent-runtime/launch-effie.ts ]; then
    pm2 describe effie >/dev/null 2>&1 || pm2 start "scripts/_local/agent-runtime/launch-effie.ts" --name effie --interpreter "$(which tsx)" 2>&1 || true
  fi

  pm2 save 2>&1 || true
  echo

  echo "=== STEP 5: RESTORE CLOUDFLARED TUNNELS IF MISSING ==="
  if ! pgrep -f "cloudflared tunnel run matilda" >/dev/null 2>&1; then
    nohup cloudflared tunnel run matilda > "$HOME/matilda.log" 2>&1 &
    echo "Started matilda tunnel"
  else
    echo "Matilda tunnel already running"
  fi

  if ! pgrep -f "cloudflared tunnel run cade" >/dev/null 2>&1; then
    nohup cloudflared tunnel run cade > "$HOME/cade.log" 2>&1 &
    echo "Started cade tunnel"
  else
    echo "Cade tunnel already running"
  fi

  if ! pgrep -f "cloudflared tunnel run effie" >/dev/null 2>&1; then
    nohup cloudflared tunnel run effie > "$HOME/effie.log" 2>&1 &
    echo "Started effie tunnel"
  else
    echo "Effie tunnel already running"
  fi
  echo

  echo "=== STEP 6: PORT CHECKS ==="
  lsof -nP -iTCP:3000 -sTCP:LISTEN || echo "Port 3000 not listening"
  lsof -nP -iTCP:8080 -sTCP:LISTEN || echo "Port 8080 not listening"
  lsof -nP -iTCP:5432 -sTCP:LISTEN || echo "Port 5432 not listening"
  echo

  echo "=== STEP 7: HTTP CHECKS ==="
  curl -I --max-time 5 http://localhost:3000 2>&1 || echo "localhost:3000 unreachable"
  curl -I --max-time 5 http://localhost:8080 2>&1 || echo "localhost:8080 unreachable"
  echo

  echo "=== STEP 8: FINAL PROCESS STATE ==="
  docker ps 2>&1 || true
  echo
  pm2 list 2>&1 || true
  echo
  ps aux | grep cloudflared | grep -v grep || true
  echo

  echo "=== STEP 9: RECENT LOG TAILS ==="
  [ -f "$HOME/matilda.log" ] && { echo "--- matilda.log ---"; tail -n 20 "$HOME/matilda.log"; } || true
  [ -f "$HOME/cade.log" ] && { echo "--- cade.log ---"; tail -n 20 "$HOME/cade.log"; } || true
  [ -f "$HOME/effie.log" ] && { echo "--- effie.log ---"; tail -n 20 "$HOME/effie.log"; } || true
  echo

  echo "=== FINAL READ ==="
  echo "If localhost:3000 or localhost:8080 returns HTTP headers, dashboard recovery succeeded."
  echo "If Docker daemon remained unavailable, open Docker Desktop and rerun this script."
  echo "If ports remain closed but Docker is up, inspect docker compose logs next."
  echo
} > "${OUT}"

echo "${OUT}"
