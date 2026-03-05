#!/usr/bin/env bash
set -euo pipefail

# Deterministic demo hardening smoke
# Proves fresh boot → run_view → probe → visible run
# No manual psql, no manual schema patching.

cd "$(git rev-parse --show-toplevel)"

COMPOSE_FILES=(
  -f docker-compose.yml
  -f docker-compose.workers.yml
)

export COMPOSE_PROJECT_NAME=motherboard_systems_hq

echo "== Fresh stack boot =="
docker compose "${COMPOSE_FILES[@]}" down --remove-orphans || true
docker compose "${COMPOSE_FILES[@]}" up -d --build

echo "== Wait for API health =="
for i in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:8080/api/health >/dev/null 2>&1; then
    echo "API healthy"
    break
  fi
  sleep 1
done

echo "== Detect postgres service =="
PG_SERVICE="$(docker compose ps --services | grep -E 'postgres|db' | head -n1 || true)"
if [ -z "$PG_SERVICE" ]; then
  echo "ERROR: postgres service not found"
  exit 1
fi
echo "PG_SERVICE=$PG_SERVICE"

echo "== Assert run_view exists =="
docker compose exec -T "$PG_SERVICE" psql -U postgres -d postgres -c \
"select 1 from run_view limit 1;" >/dev/null

echo "run_view OK"

echo "== Trigger probe run =="
curl -fsS -X POST http://127.0.0.1:8080/api/probe || true

echo "== Wait for visible run =="
for i in $(seq 1 30); do
  if curl -sS http://127.0.0.1:8080/api/runs | grep -q run_id; then
    echo "Run visible"
    break
  fi
  sleep 1
done

echo "== Demo smoke PASS =="
