#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== Phase 127 containerized checkpoint ==="
echo "branch: $(git branch --show-current)"
echo "head: $(git rev-parse --short HEAD)"
git status --short
docker compose ps
docker inspect --format='{{.Name}} {{.State.Status}} {{if .State.Health}}{{.State.Health.Status}}{{end}}' motherboard_systems_hq-dashboard-1
echo "=== Phase 127 containerized checkpoint complete ==="
