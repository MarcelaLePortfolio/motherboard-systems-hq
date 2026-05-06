#!/bin/bash
set -euo pipefail

echo "PHASE 705 — DOCKER DAEMON PROCESS RESET"

echo ""
echo "[1] Disk / external drive check"
df -h | grep -E "Filesystem|/System/Volumes/Data|/Volumes/Rio Drive" || true

echo ""
echo "[2] Stop stuck Docker Desktop processes"
osascript -e 'quit app "Docker"' || true
pkill -f "Docker Desktop" || true
pkill -f "com.docker.backend" || true
pkill -f "com.docker" || true
sleep 12

echo ""
echo "[3] Remove stale user socket only if present"
rm -f "$HOME/.docker/run/docker.sock" || true

echo ""
echo "[4] Relaunch Docker Desktop"
open -a Docker

echo ""
echo "[5] Wait for Docker daemon/server"
for i in $(seq 1 80); do
  if docker info 2>/dev/null | grep -q "Server Version"; then
    echo "Docker daemon ready"
    docker info | grep -E "Server Version|Docker Root Dir|Storage Driver"
    exit 0
  fi
  echo "waiting... $i"
  sleep 3
done

echo ""
echo "Docker daemon still unavailable after clean process reset."
echo "Do not rebuild yet."
df -h | grep -E "Filesystem|/System/Volumes/Data|/Volumes/Rio Drive" || true
exit 1
