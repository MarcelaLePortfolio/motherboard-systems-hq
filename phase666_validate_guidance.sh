#!/usr/bin/env bash
set -euo pipefail

echo "=== /api/guidance raw with timeout ==="
curl --max-time 8 -sS -w "\nHTTP_STATUS=%{http_code}\n" http://localhost:3000/api/guidance || true

echo
echo "=== /api/guidance-history raw with timeout ==="
curl --max-time 8 -sS -w "\nHTTP_STATUS=%{http_code}\n" http://localhost:3000/api/guidance-history || true

echo
echo "=== dashboard logs ==="
docker compose logs --tail=220 dashboard

echo
echo "=== git status ==="
git status --short
