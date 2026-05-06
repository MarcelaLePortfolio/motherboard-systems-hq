#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Docker daemon start + readiness gate"
echo "────────────────────────────────"

echo ""
echo "1) Current repo state..."
git status --short
git branch --show-current

echo ""
echo "2) Current disk state..."
df -h /

echo ""
echo "3) Attempting to start Docker Desktop..."
open -a Docker || true

echo ""
echo "4) Waiting for Docker daemon readiness..."
READY=0
for i in {1..60}; do
  if docker info >/tmp/phase704_docker_info.txt 2>/tmp/phase704_docker_info.err; then
    READY=1
    echo "Docker daemon: HEALTHY"
    break
  fi

  echo "Waiting for Docker daemon... attempt $i/60"
  sleep 5
done

if [ "$READY" != "1" ]; then
  echo ""
  echo "Docker daemon: STILL UNHEALTHY"
  cat /tmp/phase704_docker_info.err || true
  echo ""
  echo "Do not rebuild yet. Docker Desktop is still not exposing the daemon socket."
  exit 1
fi

echo ""
echo "5) Docker daemon summary..."
docker info | sed -n '1,50p'

echo ""
echo "6) Docker containers..."
docker ps

echo ""
echo "7) Safe Docker disk usage report..."
docker system df

echo ""
echo "8) Ready to rerun container revalidation:"
echo "bash PHASE704_DOCKER_RECOVERY_REVALIDATION.sh"
