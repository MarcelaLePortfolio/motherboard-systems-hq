#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

net="motherboard_systems_hq_default"

# Detect whether the composed config expects the default network to be external.
cfg="$(docker compose -f docker-compose.yml -f docker-compose.workers.yml config 2>/dev/null || true)"

expects_external="0"
if printf '%s\n' "$cfg" | awk '
  $1=="networks:" {in=1; next}
  in && $1=="services:" {exit}
  in {print}
' | grep -qE 'motherboard_systems_hq_default:|default:'; then
  # If any "external: true" appears in networks stanza, treat as external expectation.
  if printf '%s\n' "$cfg" | grep -qE 'external:\s*true'; then
    expects_external="1"
  fi
fi

if [ "$expects_external" = "1" ]; then
  docker network inspect "$net" >/dev/null 2>&1 || docker network create "$net" >/dev/null
else
  # Non-external: if a stray network exists without compose label "default", remove so compose can recreate.
  if docker network inspect "$net" >/dev/null 2>&1; then
    label="$(docker network inspect "$net" --format '{{ index .Labels "com.docker.compose.network" }}' 2>/dev/null || true)"
    if [ "$label" != "default" ]; then
      docker network rm "$net" >/dev/null 2>&1 || true
    fi
  fi
fi
