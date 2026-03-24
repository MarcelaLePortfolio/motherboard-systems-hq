#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== Phase 127 post-container status ==="
echo "branch: $(git branch --show-current)"
echo "head: $(git rev-parse --short HEAD)"
echo "working_tree:"
git status --short

echo "recent_tags:"
git tag --sort=-creatordate | head -n 8

echo "container:"
docker compose ps
docker inspect --format='{{.Name}} {{.State.Status}} {{if .State.Health}}{{.State.Health.Status}}{{end}}' motherboard_systems_hq-dashboard-1
docker compose logs dashboard --tail 20

echo "=== Phase 127 post-container status complete ==="
