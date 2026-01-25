#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

[[ -f docker-compose.workers.yml ]] || { echo "missing docker-compose.workers.yml (did you git mv it?)" >&2; exit 3; }



if [[ "" == "motherboard_systems_hq" ]]; then  echo "refusing: WORKER_PROJECT=motherboard_systems_hq (would touch main stack)" >&2
  exit 2
fi
docker compose -p "$P" -f docker-compose.workers.yml logs -f --tail=200
