#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${NEXT_PUBLIC_BASE_URL:-http://localhost:3000}"

echo "=== Route Files ==="
find app -maxdepth 6 -type f | sort | grep -E 'api|route\.ts|route\.js' || true

echo ""
echo "=== Guidance Files ==="
find . -maxdepth 6 -type f | sort | grep -E 'guidance|operator-guidance|coherence' || true

echo ""
echo "=== Probe Known Guidance Endpoints ==="
for path in \
  /api/guidance \
  /api/guidance/history \
  /events/operator-guidance \
  /api/guidance/coherence-preview \
  /api/guidance/coherence-shadow
do
  echo "GET ${BASE_URL}${path}"
  curl -i -sS "${BASE_URL}${path}" | head -40 || true
  echo ""
done

echo ""
echo "=== Dashboard Logs Route Mentions ==="
docker logs motherboard_systems_hq-dashboard-1 --tail 200 | grep -E 'guidance|coherence|404|api' || true
