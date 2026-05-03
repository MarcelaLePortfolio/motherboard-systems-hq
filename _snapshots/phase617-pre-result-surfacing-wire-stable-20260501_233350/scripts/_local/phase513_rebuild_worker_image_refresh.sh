#!/usr/bin/env bash
set -euo pipefail

docker compose build dashboard
docker compose up -d --force-recreate worker

sleep 5

echo "[1] Verify SQL inside worker image"
docker exec -i motherboard_systems_hq-worker-1 sed -n '1,18p' /app/server/worker/phase35_claim_one_pg.sql

echo
echo "[2] Worker logs"
docker logs --tail 80 motherboard_systems_hq-worker-1
