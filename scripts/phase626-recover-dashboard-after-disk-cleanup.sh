#!/usr/bin/env bash
set -euo pipefail

echo "Stopping dashboard container..."
docker compose stop dashboard || true

echo "Rebuilding and restarting dashboard..."
docker compose up -d --build dashboard

echo "Waiting for dashboard health..."
for i in {1..45}; do
  if curl -fsS http://localhost:3000/api/health >/dev/null 2>&1; then
    echo "Dashboard healthy."
    curl -fsS http://localhost:3000/api/health
    echo
    exit 0
  fi
  sleep 1
done

echo "Dashboard did not become healthy. Recent logs:"
docker compose logs --tail=120 dashboard
exit 1
