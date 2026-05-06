#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Docker hard restart at app/process layer"
echo "────────────────────────────────"

echo ""
echo "1) Repo state..."
git status --short
git branch --show-current

echo ""
echo "2) Disk state..."
df -h /
df -h /System/Volumes/Data

echo ""
echo "3) Force-stopping Docker app/backend/VM processes..."
osascript -e 'quit app "Docker"' || true
sleep 5

pkill -9 -f "/Applications/Docker.app" || true
pkill -9 -f "com.docker.backend" || true
pkill -9 -f "com.docker.vmnetd" || true
pkill -9 -f "com.apple.Virtualization.VirtualMachine" || true
sleep 8

echo ""
echo "4) Removing stale Docker runtime sockets + pid state..."
rm -rf "$HOME/.docker/run" || true
mkdir -p "$HOME/.docker/run"

rm -f "$HOME/Library/Containers/com.docker.docker/Data/docker-cli.sock" || true
rm -f /var/run/docker.sock || true

echo ""
echo "5) Clearing only Docker Desktop support state..."
rm -rf "$HOME/Library/Application Support/Docker Desktop" || true
rm -rf "$HOME/Library/Saved Application State/com.electron.docker-frontend.savedState" || true

echo ""
echo "6) Recreating docker.sock symlink..."
ln -sf "$HOME/.docker/run/docker.sock" /var/run/docker.sock || true

echo ""
echo "7) Launching Docker Desktop directly..."
open -na /Applications/Docker.app || true

echo ""
echo "8) Waiting for Docker daemon readiness..."
READY=0
for i in {1..150}; do
  if docker info >/tmp/phase704_hard_restart_info.txt 2>/tmp/phase704_hard_restart_err.txt; then
    READY=1
    echo "Docker daemon: HEALTHY"
    break
  fi

  echo "Waiting for Docker daemon... attempt $i/150"
  sleep 4
done

if [ "$READY" != "1" ]; then
  echo ""
  echo "Docker daemon: STILL UNHEALTHY AFTER HARD RESTART"
  cat /tmp/phase704_hard_restart_err.txt || true

  echo ""
  echo "Next corridor:"
  echo "- manual Docker Desktop reinstall"
  echo "- preserve repository"
  echo "- preserve local Node runtime"
  exit 1
fi

echo ""
echo "9) Docker daemon summary..."
docker info | sed -n '1,80p'

echo ""
echo "10) Docker contexts..."
docker context ls || true

echo ""
echo "11) Docker disk usage..."
docker system df || true

echo ""
echo "12) Ready for authoritative container runtime rebuild:"
echo "bash PHASE704_DOCKER_RECOVERY_REVALIDATION.sh"
