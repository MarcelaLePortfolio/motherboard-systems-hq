#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Safe disk relief + Docker restart"
echo "────────────────────────────────"

echo ""
echo "1) Repo state..."
git status --short
git branch --show-current

echo ""
echo "2) Disk state before cleanup..."
df -h /
df -h /System/Volumes/Data

echo ""
echo "3) Stopping Docker Desktop processes safely..."
osascript -e 'quit app "Docker"' || true
sleep 8
pkill -f "Docker.app" || true
pkill -f "com.docker.backend" || true
sleep 5

echo ""
echo "4) Removing Docker diagnostic/log pressure only..."
DOCKER_LOG_ROOT="$HOME/Library/Containers/com.docker.docker/Data/log"

if [ -d "$DOCKER_LOG_ROOT" ]; then
  echo "Docker log root found: $DOCKER_LOG_ROOT"
  find "$DOCKER_LOG_ROOT" -type f \( -name "*.log" -o -name "*.txt" \) -print -exec sh -c ': > "$1"' _ {} \; || true
else
  echo "Docker log root not found."
fi

echo ""
echo "5) Removing safe local temporary files..."
rm -rf /tmp/phase704_* || true
rm -rf "$TMPDIR"/phase704_* || true

echo ""
echo "6) Showing largest user-level candidates for manual review..."
du -sh "$HOME"/Library/Caches 2>/dev/null || true
du -sh "$HOME"/Downloads 2>/dev/null || true
du -sh "$HOME"/.npm 2>/dev/null || true
du -sh "$HOME"/.cache 2>/dev/null || true
du -sh "$HOME"/Library/Containers/com.docker.docker 2>/dev/null || true

echo ""
echo "7) Disk state after cleanup..."
df -h /
df -h /System/Volumes/Data

echo ""
echo "8) Starting Docker Desktop..."
open -a Docker || true

echo ""
echo "9) Waiting for Docker daemon readiness..."
READY=0
for i in {1..90}; do
  if docker info >/tmp/phase704_docker_info_after_relief.txt 2>/tmp/phase704_docker_info_after_relief.err; then
    READY=1
    echo "Docker daemon: HEALTHY"
    break
  fi

  echo "Waiting for Docker daemon... attempt $i/90"
  sleep 5
done

if [ "$READY" != "1" ]; then
  echo ""
  echo "Docker daemon: STILL UNHEALTHY"
  cat /tmp/phase704_docker_info_after_relief.err || true
  echo ""
  echo "Stop here. Do not rebuild containers yet."
  exit 1
fi

echo ""
echo "10) Docker daemon summary..."
docker info | sed -n '1,80p'

echo ""
echo "11) Docker disk usage..."
docker system df || true

echo ""
echo "12) Ready for authoritative container revalidation:"
echo "bash PHASE704_DOCKER_RECOVERY_REVALIDATION.sh"
