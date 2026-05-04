#!/usr/bin/env bash
set -euo pipefail

echo "=== Phase 632 Bootstrap Runner Audit ==="
echo
echo "Docker compose + Dockerfiles:"
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=_snapshots \
  -E "init_db|migrations|psql|postgres|docker-entrypoint-initdb|command:|entrypoint|POSTGRES" \
  docker-compose.yml Dockerfile* .dockerignore 2>/dev/null || true

echo
echo "Server startup references:"
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=_snapshots \
  -E "init_db|migrations|CREATE TABLE|ALTER TABLE|psql|Pool|POSTGRES_URL|DATABASE_URL" \
  server server.mjs scripts package.json 2>/dev/null | sed -n '1,220p'
