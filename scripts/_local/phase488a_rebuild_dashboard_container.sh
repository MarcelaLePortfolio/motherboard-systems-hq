#!/bin/bash
set -euo pipefail

echo "=== HEAD ==="
git rev-parse --short HEAD

echo
echo "=== rebuilding dashboard container from current repo state ==="
docker compose build dashboard

echo
echo "=== recreating dashboard container ==="
docker compose up -d dashboard

echo
echo "=== waiting for container to settle ==="
sleep 5

echo
echo "=== verifying container source ==="
docker exec motherboard_systems_hq-dashboard-1 sh -lc '
grep -n "deterministic-local-response\|Matilda received your request\|phase487-placeholder-stub\|Matilda placeholder online" /app/server.mjs || true
'

echo
echo "=== verifying live /api/chat ==="
curl -sS -X POST http://127.0.0.1:8080/api/chat \
  -H "Content-Type: application/json" \
  -d "{\"message\":\"status check\",\"agent\":\"matilda\"}" | python3 -m json.tool
