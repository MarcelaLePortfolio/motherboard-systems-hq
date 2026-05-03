#!/usr/bin/env bash
set -euo pipefail

echo "Container reconciliation summary"
echo
echo "Active dashboard Dockerfile: Dockerfile.dashboard"
echo "Active compose base: docker-compose.yml"
echo "Active worker compose path: docker-compose.workers.yml"
echo
echo "Historical worker compose files still present:"
printf '%s\n' \
  "docker-compose.worker.phase32.yml" \
  "docker-compose.worker.phase34.yml" \
  "docker-compose.phase31.7-worker.yml"
echo
echo "Next safe modification targets:"
printf '%s\n' \
  "Dockerfile.dashboard" \
  "docker-compose.yml" \
  "docker-compose.workers.yml"
