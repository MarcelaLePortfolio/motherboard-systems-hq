#!/usr/bin/env bash
set -euo pipefail

echo "=== Docker Containers ==="
docker ps

echo ""
echo "=== Port Mapping ==="
docker ps --format "table {{.Names}}\t{{.Ports}}"

echo ""
echo "=== Checking common ports ==="
for port in 8080 3000 3001; do
  echo "Probing http://localhost:${port} ..."
  if curl -fsS "http://localhost:${port}" >/dev/null 2>&1; then
    echo "SUCCESS: http://localhost:${port} is reachable"
  else
    echo "FAIL: http://localhost:${port} not reachable"
  fi
done

echo ""
echo "=== Dashboard Logs (last 50 lines) ==="
docker logs motherboard_systems_hq-dashboard-1 --tail 50 || true

echo ""
echo "=== Worker Logs (last 50 lines) ==="
docker logs motherboard_systems_hq-worker-1 --tail 50 || true

echo ""
echo "=== Next Step ==="
echo "1. Identify correct exposed port from 'Port Mapping'"
echo "2. Export BASE URL:"
echo "   export NEXT_PUBLIC_BASE_URL=http://localhost:<PORT>"
echo "3. Rerun:"
echo "   ./EXECUTE_PHASE675_VALIDATION_AND_CHECKPOINT.sh"
