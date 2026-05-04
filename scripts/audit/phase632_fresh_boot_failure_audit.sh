#!/usr/bin/env bash
set -euo pipefail

echo "=== Phase 632 Fresh Boot Failure Audit ==="
echo
echo "Docker compose:"
sed -n '1,120p' docker-compose.yml
echo
echo "Postgres logs:"
docker compose logs --tail=160 postgres || true
echo
echo "Postgres init directory from inside container:"
docker compose exec postgres sh -lc 'find /docker-entrypoint-initdb.d -maxdepth 3 -type f -print -exec sed -n "1,80p" {} \;' || true
echo
echo "Mounted migrations/sql directories inside dashboard:"
docker compose exec dashboard sh -lc 'find /app -maxdepth 4 \( -path "*/migrations/*" -o -path "*/server/sql/*" -o -path "*/docker-entrypoint-initdb.d/*" \) -type f | sort | sed -n "1,120p"' || true
