#!/usr/bin/env bash
set -euo pipefail

docker compose up -d --build >/dev/null
open "http://localhost:8080/?v=$(date +%s)"
sleep 4
docker logs motherboard_systems_hq-dashboard-1 --tail 200
