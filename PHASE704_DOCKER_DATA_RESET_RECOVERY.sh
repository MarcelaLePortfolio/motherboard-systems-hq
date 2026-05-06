#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Docker data reset recovery"
echo "────────────────────────────────"

echo ""
echo "1) Repo state..."
git status --short
git branch --show-current

echo ""
echo "2) Disk state before Docker data reset..."
df -h /
df -h /System/Volumes/Data

echo ""
echo "3) Confirming Docker daemon is still unavailable..."
if docker info >/tmp/phase704_pre_reset_docker_info.txt 2>/tmp/phase704_pre_reset_docker_info.err; then
  echo "Docker daemon is healthy. Stop: Docker data reset is not needed."
  exit 0
else
  cat /tmp/phase704_pre_reset_docker_info.err || true
fi

echo ""
echo "4) Stopping Docker Desktop processes..."
osascript -e 'quit app "Docker"' || true
sleep 8
pkill -f "Docker.app" || true
pkill -f "com.docker.backend" || true
pkill -f "com.apple.Virtualization.VirtualMachine" || true
sleep 5

echo ""
echo "5) Measuring Docker Desktop data before reset..."
du -sh "$HOME/Library/Containers/com.docker.docker" 2>/dev/null || true
find "$HOME/Library/Containers/com.docker.docker/Data" -maxdepth 5 -type f -size +1G -print -exec ls -lh {} \; 2>/dev/null || true

echo ""
echo "6) Removing Docker VM disk data only..."
rm -rf "$HOME/Library/Containers/com.docker.docker/Data/vms" || true
rm -rf "$HOME/Library/Containers/com.docker.docker/Data/docker.raw" || true
rm -rf "$HOME/Library/Containers/com.docker.docker/Data/Docker.raw" || true
rm -rf "$HOME/Library/Containers/com.docker.docker/Data/log" || true

echo ""
echo "7) Disk state after Docker data reset..."
df -h /
df -h /System/Volumes/Data

echo ""
echo "8) Restarting Docker Desktop..."
open -a Docker || true

echo ""
echo "9) Waiting for Docker daemon readiness after reset..."
READY=0
for i in {1..120}; do
  if docker info >/tmp/phase704_post_reset_docker_info.txt 2>/tmp/phase704_post_reset_docker_info.err; then
    READY=1
    echo "Docker daemon: HEALTHY"
    break
  fi

  echo "Waiting for Docker daemon... attempt $i/120"
  sleep 5
done

if [ "$READY" != "1" ]; then
  echo ""
  echo "Docker daemon: STILL UNHEALTHY AFTER DATA RESET"
  cat /tmp/phase704_post_reset_docker_info.err || true
  exit 1
fi

echo ""
echo "10) Docker daemon summary..."
docker info | sed -n '1,80p'

echo ""
echo "11) Docker disk usage after reset..."
docker system df || true

echo ""
echo "12) Ready for container rebuild/revalidation:"
echo "bash PHASE704_DOCKER_RECOVERY_REVALIDATION.sh"
