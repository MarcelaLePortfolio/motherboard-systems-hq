#!/usr/bin/env bash
set -euo pipefail

# refuse if transcript artifacts got pasted into this file
rg -n '^heredoc>' "-e" >/dev/null && { echo "refusing: heredoc> prefix detected in -e" >&2; exit 9; } || true

cd "$(git rev-parse --show-toplevel)"
COMPOSE="docker-compose.workers.yml"
[[ -f "$COMPOSE" ]] || { echo "missing $COMPOSE (did you git mv it?)" >&2; exit 3; }
P="${WORKER_PROJECT:-motherboard_workers}"
if [[ "$P" == "motherboard_systems_hq" ]]; then
  echo "refusing: WORKER_PROJECT=motherboard_systems_hq (would touch main stack)" >&2
  exit 2
fi
docker compose -p "$P" -f "$COMPOSE" logs -f --tail=200
