
#!/bin/bash

set -euo pipefail

echo "===== PHASE 719 INSPECT SERVED STATIC SOURCE ====="

DASHBOARD_CONTAINER="$(docker compose ps -q dashboard)"

echo "[1] Dashboard container: ${DASHBOARD_CONTAINER}"

echo ""

echo "[2] Find bridge files inside dashboard container"

docker exec "$DASHBOARD_CONTAINER" sh -lc 'find / -name phase530_visible_panels_bridge.js 2>/dev/null | head -20'

echo ""

echo "[3] Search semantic markers inside dashboard container copies"

docker exec "$DASHBOARD_CONTAINER" sh -lc '

for f in $(find / -name phase530_visible_panels_bridge.js 2>/dev/null | head -20); do

  echo "--- $f"

  grep -nE "Recovery Artifact|Execution Plan|Completion Summary|Needs Review|Actionable|Rendered Preview" "$f" | head -10 || true

done

'

echo ""

echo "[4] Show compose static mount clues"

grep -nE "dashboard|volumes|public|command|build|image" docker-compose.yml docker-compose.yaml compose.yml compose.yaml 2>/dev/null || true

echo "===== COMPLETE ====="

