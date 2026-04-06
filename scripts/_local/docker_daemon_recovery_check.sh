#!/usr/bin/env bash
set -u

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/docker_daemon_recovery_check_$(date +%Y%m%d_%H%M%S).txt"

{
echo "DOCKER DAEMON RECOVERY CHECK"
echo "Timestamp: $(date)"
echo

echo "==== CURRENT FINDING ===="
echo "Dashboard on :8080 is down because Docker daemon is unavailable."
echo

echo "==== DOCKER APP PRESENCE ===="
ls -ld /Applications/Docker.app 2>/dev/null || true
echo

echo "==== DOCKER DESKTOP PROCESS BEFORE START ===="
ps aux | grep -i "/Applications/Docker.app" | grep -v grep || true
ps aux | grep -i "Docker Desktop" | grep -v grep || true
echo

echo "==== ATTEMPTING TO START DOCKER DESKTOP ===="
open -a Docker || true
echo "Start command issued at: $(date)"
echo

echo "==== WAITING FOR DAEMON ===="
READY=0
for i in $(seq 1 24); do
  if docker info >/dev/null 2>&1; then
    READY=1
    echo "Docker daemon became available on attempt $i"
    break
  fi
  echo "Attempt $i: docker daemon not yet available"
  sleep 5
done
echo

echo "==== DOCKER INFO ===="
docker info 2>&1 || true
echo

echo "==== DOCKER PS ===="
docker ps 2>&1 || true
echo

echo "==== DOCKER COMPOSE PS ===="
if docker compose version >/dev/null 2>&1; then
  docker compose ps 2>&1 || true
elif command -v docker-compose >/dev/null 2>&1; then
  docker-compose ps 2>&1 || true
else
  echo "No docker compose command available"
fi
echo

echo "==== PORT CHECK ===="
lsof -nP -iTCP:8080 -sTCP:LISTEN || true
lsof -nP -iTCP:3000 -sTCP:LISTEN || true
lsof -nP -iTCP:5432 -sTCP:LISTEN || true
echo

echo "==== HTTP CHECK ===="
curl -I -sS http://127.0.0.1:8080/ || true
echo
curl -I -sS http://127.0.0.1:3000/ || true
echo

echo "==== RESULT ===="
if [ "$READY" -eq 1 ]; then
  echo "Docker daemon recovered."
else
  echo "Docker daemon did not recover during this check window."
fi
echo

} > "$OUT"

echo "Recovery check written to:"
echo "$OUT"

echo
echo "----- RECOVERY CHECK PREVIEW -----"
sed -n '1,240p' "$OUT"
