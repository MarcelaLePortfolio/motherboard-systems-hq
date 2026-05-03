#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for dashboard container health..."
for i in {1..30}; do
  STATUS="$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' motherboard_systems_hq-dashboard-1 2>/dev/null || true)"
  echo "dashboard health: ${STATUS}"
  if [ "$STATUS" = "healthy" ]; then
    break
  fi
  sleep 2
done

echo
docker compose ps
echo
docker compose logs --tail=50 dashboard
echo
git status --short
