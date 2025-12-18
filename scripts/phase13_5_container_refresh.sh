#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

docker compose down
docker compose up -d --build

echo
echo "Dashboard: http://127.0.0.1:8080/dashboard"
echo "Logs: docker logs -f --tail=200 motherboard_systems_hq-dashboard-1"
