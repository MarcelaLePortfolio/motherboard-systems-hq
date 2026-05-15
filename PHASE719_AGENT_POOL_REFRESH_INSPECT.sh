
#!/bin/bash

set -euo pipefail

echo "===== PHASE 719 AGENT POOL REFRESH INSPECT ====="

echo ""

echo "[1] Locate renderAgents calls"

grep -n "renderAgents" public/js/phase530_visible_panels_bridge.js || true

echo ""

echo "[2] Show refresh section"

grep -n "async function refresh" public/js/phase530_visible_panels_bridge.js || true

sed -n '720,820p' public/js/phase530_visible_panels_bridge.js

echo ""

echo "[3] Runtime syntax check"

node --check public/js/phase530_visible_panels_bridge.js

echo ""

echo "===== COMPLETE ====="

