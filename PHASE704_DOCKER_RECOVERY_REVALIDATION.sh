#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Docker daemon recovery + container revalidation"
echo "────────────────────────────────"

echo ""
echo "1) Checking repo state..."
git status --short
git branch --show-current

echo ""
echo "2) Checking disk space..."
df -h

echo ""
echo "3) Checking Docker daemon..."
if docker info >/tmp/phase704_docker_info.txt 2>/tmp/phase704_docker_info.err; then
  echo "Docker daemon: HEALTHY"
  cat /tmp/phase704_docker_info.txt | sed -n '1,40p'
else
  echo "Docker daemon: UNHEALTHY"
  cat /tmp/phase704_docker_info.err || true
  echo ""
  echo "Stop here. Open Docker Desktop, wait until it fully starts, then rerun:"
  echo "bash PHASE704_DOCKER_RECOVERY_REVALIDATION.sh"
  exit 1
fi

echo ""
echo "4) Checking containers..."
docker ps

echo ""
echo "5) Rebuilding container runtime..."
docker compose down --remove-orphans
docker compose up -d --build

echo ""
echo "6) Waiting for dashboard container..."
sleep 8

echo ""
echo "7) Checking containers after rebuild..."
docker ps

echo ""
echo "8) Validating dashboard on port 3000..."
curl -I http://localhost:3000 | sed -n '1,20p'

echo ""
echo "9) Validating advisory chat contract under container runtime..."
curl -sS http://localhost:3000/api/chat \
  -H 'Content-Type: application/json' \
  -d '{"message":"confirm advisory chat contract"}' | tee /tmp/phase704_chat_response.json

echo ""
echo "10) Validating guidance API under container runtime..."
curl -sS http://localhost:3000/api/guidance | tee /tmp/phase704_guidance_response.json | head -c 1000
echo ""

echo ""
echo "11) Capturing compose status..."
docker compose ps | tee /tmp/phase704_compose_ps.txt

echo ""
echo "Phase 704 recovery validation complete."
echo "Review outputs above before snapshot/tag."
