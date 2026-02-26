#!/usr/bin/env bash
set -euo pipefail

net="motherboard_systems_hq_default"

# If the network exists but isn't a compose-managed default network for this project, remove it.
if docker network inspect "$net" >/dev/null 2>&1; then
  label="$(docker network inspect "$net" --format '{{ index .Labels "com.docker.compose.network" }}' 2>/dev/null || true)"
  if [ "$label" != "default" ]; then
    docker network rm "$net" >/dev/null 2>&1 || true
  fi
fi
