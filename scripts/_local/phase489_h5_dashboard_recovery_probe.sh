#!/usr/bin/env bash
set -euo pipefail

echo "=== CONTAINER STATUS ==="
docker compose ps || true
echo

echo "=== DASHBOARD CONTAINER LOGS (last 200 lines) ==="
docker logs motherboard_systems_hq-dashboard-1 --tail 200 || true
echo

echo "=== POSTGRES CONTAINER LOGS (last 100 lines) ==="
docker logs motherboard_systems_hq-postgres-1 --tail 100 || true
echo

echo "=== PORT CHECK (8080) ==="
lsof -i :8080 || true
echo

echo "=== HTTP CHECK ==="
curl -i -s --max-time 3 http://localhost:8080 | sed -n '1,80p' || true
echo

echo "=== HARD RESTART (CLEAN REBUILD) ==="
docker compose down
docker compose up -d --build
echo

echo "=== POST-RESTART STATUS ==="
docker compose ps
echo

echo "=== POST-RESTART HTTP CHECK ==="
curl -i -s --max-time 3 http://localhost:8080 | sed -n '1,80p' || true
echo

echo "=== OPEN DASHBOARD ==="
open "http://localhost:8080/?v=$(date +%s)"
