#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "=== LOCAL dashboard.html slice ==="
nl -ba public/dashboard.html | sed -n '145,165p'

echo
echo "=== CONTAINER /app/public/dashboard.html slice ==="
docker exec motherboard_systems_hq-dashboard-1 sh -lc 'nl -ba /app/public/dashboard.html | sed -n "145,165p"'

echo
echo "=== CONTAINER live-served file grep ==="
docker exec motherboard_systems_hq-dashboard-1 sh -lc 'grep -n "phase61-telemetry-column\|activity-panels-heading" /app/public/dashboard.html || true'
