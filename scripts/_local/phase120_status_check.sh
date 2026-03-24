#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== phase120 status check ==="
echo "branch: $(git branch --show-current)"
echo "head: $(git rev-parse --short HEAD)"
echo "working_tree:"
git status --short

echo "tag:"
git tag --list | grep '^v120-dashboard-consumption-adapter-golden$'

echo "remote_head:"
git ls-remote --heads origin "$(git branch --show-current)"

echo "container:"
docker compose ps
docker inspect --format='{{.Name}} {{.State.Status}} {{if .State.Health}}{{.State.Health.Status}}{{end}}' motherboard_systems_hq-dashboard-1
