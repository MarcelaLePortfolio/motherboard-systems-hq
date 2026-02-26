#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p _diag/phase46
docker compose ps --format json > _diag/phase46/compose_ps_before_shutdown.json 2>/dev/null || true
docker compose down --remove-orphans
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | sed -n '1,40p' > _diag/phase46/ps_after_shutdown.txt
lsof -nP -iTCP:8080 -sTCP:LISTEN >/dev/null 2>&1 && exit 1 || true
