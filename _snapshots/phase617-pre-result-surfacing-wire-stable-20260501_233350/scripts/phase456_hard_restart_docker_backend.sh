#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase456_hard_restart_docker_backend.txt"

{
  echo "PHASE 456 — HARD RESTART DOCKER BACKEND"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "=== PRECHECK ==="
  df -h .
  echo
  git rev-parse --abbrev-ref HEAD
  git rev-parse HEAD
  echo
  git status --short || true
  echo

  echo "=== BEFORE: DOCKER PROCESS SNAPSHOT ==="
  ps aux | grep -i "[d]ocker" || true
  echo

  echo "=== STEP 1: CLEANLY QUIT DOCKER DESKTOP ==="
  osascript -e 'tell application "Docker Desktop" to quit' 2>/dev/null || true
  sleep 8
  echo

  echo "=== STEP 2: FORCE-STOP USER-LEVEL DOCKER PROCESSES ==="
  pkill -9 -f "/Applications/Docker.app/Contents/MacOS/com.docker.backend" 2>/dev/null || true
  pkill -9 -f "/Applications/Docker.app/Contents/Resources/bin/cagent" 2>/dev/null || true
  pkill -9 -f "Docker Desktop.app/Contents/MacOS/Docker Desktop" 2>/dev/null || true
  pkill -9 -f "/Applications/Docker.app/Contents/MacOS/com.docker.build" 2>/dev/null || true
  sleep 5
  echo

  echo "=== STEP 3: REMOVE ONLY STALE USER RUNTIME SOCKETS ==="
  rm -f "$HOME/.docker/run/docker.sock" 2>/dev/null || true
  find "$HOME/.docker/run" -maxdepth 1 \( -type s -o -type p \) -print -delete 2>/dev/null || true
  mkdir -p "$HOME/.docker/run"
  echo
  ls -la "$HOME/.docker/run" 2>/dev/null || true
  echo

  echo "=== STEP 4: START DOCKER DESKTOP ==="
  open -a Docker
  echo

  echo "=== STEP 5: WAIT FOR DOCKER DAEMON ==="
  ATTEMPTS=0
  MAX_ATTEMPTS=72
  while ! docker info >/dev/null 2>&1; do
    ATTEMPTS=$((ATTEMPTS + 1))
    echo "Docker daemon not ready yet (attempt ${ATTEMPTS}/${MAX_ATTEMPTS})..."
    if [ "$ATTEMPTS" -ge "$MAX_ATTEMPTS" ]; then
      echo
      echo "Docker daemon failed to become ready after hard restart."
      echo
      echo "=== FAILURE SNAPSHOT ==="
      ps aux | grep -i "[d]ocker" || true
      echo
      ls -la "$HOME/.docker/run" 2>/dev/null || true
      echo
      echo "=== RECENT LOG SIGNALS ==="
      grep -RniE "ExitBadState|no space left|fatal|panic|error|failed|unable|docker.sock|socket|vmnetd|virtualization" \
        "$HOME/Library/Containers/com.docker.docker/Data/log" 2>/dev/null | tail -n 200 || true
      exit 1
    fi
    sleep 5
  done

  echo "Docker daemon is ready."
  echo

  echo "=== STEP 6: START EXISTING COMPOSE STACK ONLY ==="
  docker compose up -d
  echo

  echo "=== STEP 7: VERIFY STACK ==="
  docker compose ps || true
  echo
  lsof -nP -iTCP:8080 -sTCP:LISTEN || true
  lsof -nP -iTCP:3000 -sTCP:LISTEN || true
  echo
  curl -I --max-time 10 http://localhost:8080 || true
  curl -I --max-time 10 http://localhost:3000 || true
  echo

  echo "=== STEP 8: DASHBOARD LOGS ==="
  for name in $(docker ps -a --format '{{.Names}}' | grep -i 'dashboard\|motherboard' || true); do
    echo "----- LOGS: $name -----"
    docker logs --tail 120 "$name" 2>&1 || true
    echo
  done
} | tee "$OUT"
