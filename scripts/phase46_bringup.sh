#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mkdir -p _diag/phase46

# Ensure the composed network expectation is satisfied (external vs compose-managed).
bash scripts/_lib/ensure_phase46_network.sh

docker compose -f docker-compose.yml -f docker-compose.workers.yml down --remove-orphans >/dev/null 2>&1 || true
docker compose -f docker-compose.yml -f docker-compose.workers.yml up -d --build

bash scripts/_lib/wait_tcp.sh 127.0.0.1 8080 90

code="$(curl -sS -o /dev/null -w "%{http_code}" "http://127.0.0.1:8080/" || echo "000")"
if [ "$code" = "000" ]; then
  echo "ERROR: no HTTP response on http://127.0.0.1:8080/ (code=000)" >&2
  docker compose -f docker-compose.yml -f docker-compose.workers.yml ps || true
  exit 1
fi

docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | sed -n '1,80p' > _diag/phase46/ps_table.txt
