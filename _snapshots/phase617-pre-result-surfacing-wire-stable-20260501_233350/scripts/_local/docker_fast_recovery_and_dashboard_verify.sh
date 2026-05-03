#!/usr/bin/env bash
set -u

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/docker_fast_recovery_and_dashboard_verify_$(date +%Y%m%d_%H%M%S).txt"

compose_up() {
  if docker compose version >/dev/null 2>&1; then
    docker compose up -d
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose up -d
  else
    echo "No docker compose command available"
    return 1
  fi
}

compose_ps() {
  if docker compose version >/dev/null 2>&1; then
    docker compose ps
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose ps
  else
    echo "No docker compose command available"
    return 1
  fi
}

{
echo "DOCKER FAST RECOVERY AND DASHBOARD VERIFY"
echo "Timestamp: $(date)"
echo

echo "==== STEP 1: QUIT DOCKER DESKTOP ===="
osascript -e 'tell application "Docker" to quit' 2>/dev/null || true
sleep 5
echo "Quit signal sent"
echo

echo "==== STEP 2: CLEAN STUCK DOCKER DESKTOP PROCESSES ===="
pkill -f "/Applications/Docker.app" 2>/dev/null || true
pkill -f "com.docker.backend" 2>/dev/null || true
pkill -f "docker-cagent.sock" 2>/dev/null || true
sleep 3
ps aux | grep -i "/Applications/Docker.app" | grep -v grep || true
ps aux | grep -i "com.docker.backend" | grep -v grep || true
echo

echo "==== STEP 3: START DOCKER DESKTOP ===="
open -a Docker
echo "Start command issued at: $(date)"
echo

echo "==== STEP 4: WAIT FOR DOCKER DAEMON ===="
READY=0
for i in $(seq 1 36); do
  if docker info >/dev/null 2>&1; then
    READY=1
    echo "Docker daemon became available on attempt $i"
    break
  fi
  echo "Attempt $i: daemon not ready"
  sleep 5
done
echo

echo "==== STEP 5: DOCKER STATUS ===="
docker info 2>&1 || true
echo
docker ps 2>&1 || true
echo

echo "==== STEP 6: RESTART CONTAINERIZED STACK ===="
if [ "$READY" -eq 1 ]; then
  compose_up 2>&1 || true
else
  echo "Skipped compose restart because daemon is unavailable"
fi
echo

echo "==== STEP 7: COMPOSE STATUS ===="
compose_ps 2>&1 || true
echo

echo "==== STEP 8: PORT CHECK ===="
lsof -nP -iTCP:8080 -sTCP:LISTEN || true
lsof -nP -iTCP:3000 -sTCP:LISTEN || true
lsof -nP -iTCP:5432 -sTCP:LISTEN || true
echo

echo "==== STEP 9: DASHBOARD HTTP VERIFY ===="
curl -I -sS http://127.0.0.1:8080/ || true
echo
curl -I -sS http://127.0.0.1:8080/events/ops || true
echo
curl -I -sS http://127.0.0.1:8080/events/reflections || true
echo
curl -I -sS http://127.0.0.1:8080/events/operator-guidance || true
echo

echo "==== STEP 10: LOCAL :3000 CHECK ===="
curl -I -sS http://127.0.0.1:3000/ || true
echo

echo "==== FINAL RESULT ===="
if [ "$READY" -eq 1 ]; then
  echo "Docker daemon recovered."
else
  echo "Docker daemon did NOT recover."
fi
echo

} > "$OUT"

echo "Recovery report written to:"
echo "$OUT"

echo
echo "----- RECOVERY REPORT PREVIEW -----"
sed -n '1,260p' "$OUT"
