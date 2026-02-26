#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

net="motherboard_systems_hq_default"

cfg="$(docker compose -f docker-compose.yml -f docker-compose.workers.yml config 2>/dev/null || true)"

expects_external="$(
  printf '%s\n' "$cfg" | awk '
    BEGIN { inside=0; ext=0 }
    /^networks:/ { in_nets=1; next }
    in_nets && /^services:/ { in_nets=0 }
    in_nets && /^  motherboard_systems_hq_default:/ { inside=1; next }
    in_nets && inside && /^  [A-Za-z0-9_.-]+:$/ { inside=0 }
    in_nets && inside && $0 ~ /external:[[:space:]]*true/ { ext=1 }
    END { print ext }
  '
)"

if [ "$expects_external" = "1" ]; then
  docker network inspect "$net" >/dev/null 2>&1 || docker network create "$net" >/dev/null
else
  if docker network inspect "$net" >/dev/null 2>&1; then
    label="$(docker network inspect "$net" --format '{{ index .Labels "com.docker.compose.network" }}' 2>/dev/null || true)"
    if [ "$label" != "default" ]; then
      docker network rm "$net" >/dev/null 2>&1 || true
    fi
  fi
fi
