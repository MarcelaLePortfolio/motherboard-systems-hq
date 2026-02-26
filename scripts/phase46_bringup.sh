#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p _diag/phase46
docker compose down --remove-orphans >/dev/null 2>&1 || true
docker compose -f docker-compose.yml -f docker-compose.workers.yml up -d --build
bash scripts/_lib/wait_http.sh "http://127.0.0.1:8080/api/runs" 90
curl -fsS "http://127.0.0.1:8080/api/runs" >/dev/null
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | sed -n '1,20p' > _diag/phase46/ps_table.txt
