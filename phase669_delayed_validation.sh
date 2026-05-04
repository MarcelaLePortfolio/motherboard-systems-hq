#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for dashboard readiness window..."
sleep 5

echo "=== docker compose ps ==="
docker compose ps

echo
echo "=== /api/guidance delayed ==="
curl --max-time 8 -sS -w "\nHTTP_STATUS=%{http_code}\n" http://localhost:3000/api/guidance || true

echo
echo "=== /api/guidance-history delayed ==="
curl --max-time 8 -sS -w "\nHTTP_STATUS=%{http_code}\n" http://localhost:3000/api/guidance-history || true

echo
echo "=== dashboard logs ==="
docker compose logs --tail=180 dashboard

echo
echo "=== git status ==="
git status --short
