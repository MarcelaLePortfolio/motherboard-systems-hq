#!/usr/bin/env bash
set -euo pipefail

echo "────────────────────────────────"
echo "Phase 704: Run authoritative container revalidation"
echo "────────────────────────────────"

echo ""
echo "1) Repo state..."
git status --short
git branch --show-current

echo ""
echo "2) Confirming Docker daemon health..."
docker info >/tmp/phase704_revalidation_docker_info.txt
echo "Docker daemon: HEALTHY"

echo ""
echo "3) Running existing Phase 704 recovery revalidation script..."
bash PHASE704_DOCKER_RECOVERY_REVALIDATION.sh

echo ""
echo "4) Final compose status..."
docker compose ps || true

echo ""
echo "5) Final Docker container list..."
docker ps

echo ""
echo "Phase 704 authoritative container revalidation runner complete."
