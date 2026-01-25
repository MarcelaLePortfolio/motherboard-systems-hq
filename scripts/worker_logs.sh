#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
P="${WORKER_PROJECT:-motherboard_workers}"

if [[ "" == "motherboard_systems_hq" ]]; then
  echo "refusing: WORKER_PROJECT=motherboard_systems_hq (would touch main stack)" >&2
  exit 2
fi
docker compose -p "$P" -f docker-compose.worker.yml logs -f --tail=200
