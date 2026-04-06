#!/usr/bin/env bash
set -u

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/docker_desktop_state_probe_$(date +%Y%m%d_%H%M%S).txt"

{
echo "DOCKER DESKTOP STATE PROBE"
echo "Timestamp: $(date)"
echo

echo "==== PURPOSE ===="
echo "Probe Docker Desktop state without mutating application code."
echo "This is an environment/runtime investigation only."
echo

echo "==== DOCKER BINARY / CONTEXT ===="
which docker || true
docker context ls 2>&1 || true
docker context inspect desktop-linux 2>&1 || true
echo

echo "==== DOCKER ENVIRONMENT VARIABLES ===="
env | grep -E '^DOCKER|^COLIMA|^LIMA' || true
echo

echo "==== SOCKET / RUN PATH CHECKS ===="
ls -la "$HOME/.docker" 2>/dev/null || true
echo
ls -la "$HOME/.docker/run" 2>/dev/null || true
echo
ls -la "$HOME/.docker/desktop" 2>/dev/null || true
echo
ls -la "$HOME/Library/Containers/com.docker.docker/Data" 2>/dev/null || true
echo
find "$HOME/Library/Containers/com.docker.docker/Data" -maxdepth 3 \( -name '*.sock' -o -name 'docker.pid' -o -name 'backend.pid' \) 2>/dev/null | sort || true
echo

echo "==== DOCKER PROCESSES ===="
ps aux | grep -i '/Applications/Docker.app' | grep -v grep || true
ps aux | grep -i 'com.docker.backend' | grep -v grep || true
ps aux | grep -i 'vpnkit\|qemu\|linuxkit\|containerd\|dockerd' | grep -v grep || true
echo

echo "==== DOCKER CLIENT / SERVER ===="
docker version 2>&1 || true
echo
docker info 2>&1 || true
echo

echo "==== DESKTOP LOG LOCATIONS ===="
find "$HOME/Library/Containers/com.docker.docker/Data/log" -maxdepth 3 -type f 2>/dev/null | sort || true
echo

echo "==== RECENT DESKTOP LOG TAILS ===="
for f in \
  "$HOME/Library/Containers/com.docker.docker/Data/log/host/com.docker.backend.log" \
  "$HOME/Library/Containers/com.docker.docker/Data/log/host/com.docker.supervisor.log" \
  "$HOME/Library/Containers/com.docker.docker/Data/log/vm/dockerd.log" \
  "$HOME/Library/Containers/com.docker.docker/Data/log/host/docker.log"
do
  if [ -f "$f" ]; then
    echo "---- $f ----"
    tail -n 120 "$f" 2>/dev/null || true
    echo
  fi
done

echo "==== LOCAL DASHBOARD STATUS CHECK ===="
lsof -nP -iTCP:3000 -sTCP:LISTEN || true
curl -I -sS http://127.0.0.1:3000/ || true
echo

echo "==== DOCKERIZED DASHBOARD STATUS CHECK ===="
lsof -nP -iTCP:8080 -sTCP:LISTEN || true
curl -I -sS http://127.0.0.1:8080/ || true
echo

echo "==== BOUNDARY-SAFE SUMMARY ===="
echo "If desktop-linux context exists but docker.sock is missing/unreachable,"
echo "the next step remains Docker Desktop remediation rather than repo mutation."
echo

} > "$OUT"

echo "Docker Desktop probe written to:"
echo "$OUT"

echo
echo "----- PROBE PREVIEW -----"
sed -n '1,320p' "$OUT"
