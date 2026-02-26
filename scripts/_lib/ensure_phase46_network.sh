#!/usr/bin/env bash
set -euo pipefail

net="motherboard_systems_hq_default"
docker network inspect "$net" >/dev/null 2>&1 || docker network create "$net" >/dev/null
