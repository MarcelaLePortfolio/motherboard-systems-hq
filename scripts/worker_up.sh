#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
docker network inspect motherboard_systems_hq_default >/dev/null 2>&1 || {
  echo "main network missing; bring up main stack first: docker compose -p motherboard_systems_hq up -d" >&2
  exit 1
}
P="${WORKER_PROJECT:-motherboard_workers}"

if [[ "" == "motherboard_systems_hq" ]]; then
  echo "refusing: WORKER_PROJECT=motherboard_systems_hq (would touch main stack)" >&2
  exit 2
fi
N="${WORKER_N:-2}"
docker compose -p "$P" -f docker-compose.worker.yml up -d --scale worker="$N"
docker ps --format '{{.Names}}' | rg "^${P}-worker-" || true
echo "workers_up project=$P n=$N"
