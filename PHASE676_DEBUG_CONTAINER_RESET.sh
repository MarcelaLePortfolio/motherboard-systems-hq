#!/usr/bin/env bash
set -euo pipefail

echo "=== Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "=== Dashboard logs ==="
docker logs motherboard_systems_hq-dashboard-1 --tail 120 || true

echo ""
echo "=== Worker logs ==="
docker logs motherboard_systems_hq-worker-1 --tail 80 || true

echo ""
echo "=== Port probe ==="
for i in {1..10}; do
  echo "Attempt $i: http://localhost:3000"
  curl -i -sS http://localhost:3000 | head -40 || true
  sleep 2
done
