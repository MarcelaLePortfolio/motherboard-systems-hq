#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

COMPOSE="docker-compose.workers.yml"
[[ -f "" ]] || { echo "missing  (did you git mv it?)" >&2; exit 3; }


P="${WORKER_PROJECT:-motherboard_workers}"

if [[ "" == "motherboard_systems_hq" ]]; then
  echo "refusing: WORKER_PROJECT=motherboard_systems_hq (would touch main stack)" >&2
  exit 2
fi
docker compose -p "$P" -f docker-compose.workers.yml down
docker ps --format '{{.Names}}' | rg "^${P}-worker-" && exit 1 || echo "workers_down project=$P"
