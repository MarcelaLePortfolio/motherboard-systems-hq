#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 456: RESTORE DOCKER DAEMON AND DASHBOARD ==="
echo
echo "--- PRECHECK ---"
df -h .
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
echo
git status --short || true
echo

echo "--- STOP DOCKER DESKTOP PROCESSES CLEANLY ---"
osascript -e 'tell application "Docker Desktop" to quit' 2>/dev/null || true
sleep 5
pkill -f "Docker Desktop" 2>/dev/null || true
pkill -f com.docker.backend 2>/dev/null || true
pkill -f com.docker.vpnkit 2>/dev/null || true
pkill -f com.docker.virtualization 2>/dev/null || true
sleep 5

echo "--- REMOVE ONLY STALE SOCKETS/RUNTIME PIPES ---"
rm -f "$HOME/.docker/run/docker.sock" 2>/dev/null || true
find "$HOME/.docker/run" -maxdepth 1 \( -type s -o -type p \) -print -delete 2>/dev/null || true
mkdir -p "$HOME/.docker/run"
echo

echo "--- START DOCKER DESKTOP ---"
open -a Docker

echo "--- WAIT FOR DAEMON SOCKET ---"
ATTEMPTS=0
MAX_ATTEMPTS=72
while ! docker info >/dev/null 2>&1; do
  ATTEMPTS=$((ATTEMPTS + 1))
  echo "Docker daemon not ready yet (attempt ${ATTEMPTS}/${MAX_ATTEMPTS})..."
  if [ "$ATTEMPTS" -ge "$MAX_ATTEMPTS" ]; then
    echo
    echo "Docker daemon failed to become ready."
    echo "--- DOCKER PROCESS SNAPSHOT ---"
    ps aux | grep -i "[d]ocker" || true
    echo
    echo "--- SOCKET DIR ---"
    ls -la "$HOME/.docker/run" 2>/dev/null || true
    exit 1
  fi
  sleep 5
done

echo "Docker daemon is ready."
echo

echo "--- START EXISTING COMPOSE STACK ONLY ---"
docker compose up -d

echo
echo "--- COMPOSE STATE ---"
docker compose ps || true
echo

echo "--- PORT CHECK ---"
lsof -nP -iTCP:8080 -sTCP:LISTEN || true
lsof -nP -iTCP:3000 -sTCP:LISTEN || true
echo

echo "--- HTTP CHECK ---"
curl -I --max-time 10 http://localhost:8080 || true
curl -I --max-time 10 http://localhost:3000 || true
echo

echo "--- DASHBOARD LOGS ---"
for name in $(docker ps -a --format '{{.Names}}' | grep -i 'dashboard\|motherboard' || true); do
  echo "----- LOGS: $name -----"
  docker logs --tail 120 "$name" 2>&1 || true
  echo
done
