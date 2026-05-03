#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v120-dashboard-consumption-adapter-golden"

echo "=== Phase 120 container verification ==="

git status --short
git tag --list | grep "^${TAG}$"

docker compose ps
docker compose build dashboard
docker compose up -d dashboard

echo "Waiting for dashboard container health..."
for i in {1..30}; do
  STATUS="$(docker inspect --format='{{.State.Health.Status}}' motherboard_systems_hq-dashboard-1 2>/dev/null || true)"
  if [[ "$STATUS" == "healthy" ]]; then
    break
  fi
  sleep 2
done

docker compose ps
docker inspect --format='{{.State.Status}} {{if .State.Health}}{{.State.Health.Status}}{{end}}' motherboard_systems_hq-dashboard-1
docker compose logs dashboard --tail 50

echo "=== Phase 120 container verification complete ==="
