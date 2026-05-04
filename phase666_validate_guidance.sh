#!/usr/bin/env bash
set -euo pipefail

echo "=== /api/guidance ==="
curl -s http://localhost:3000/api/guidance | jq

echo
echo "=== /api/guidance-history ==="
curl -s http://localhost:3000/api/guidance-history | jq

echo
echo "=== dashboard logs ==="
docker compose logs --tail=160 dashboard

echo
echo "=== git status ==="
git status --short
