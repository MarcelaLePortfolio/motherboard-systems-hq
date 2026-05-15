
#!/bin/bash

set -euo pipefail

echo "===== PHASE 719 SERVED SEMANTIC UI VERIFY ====="

echo "[1] Local semantic markers"

grep -nE "Recovery Artifact|Execution Plan|Completion Summary|Needs Review|Actionable|Rendered Preview" public/js/phase530_visible_panels_bridge.js | head -30 || true

echo ""

echo "[2] Served semantic markers"

curl -sS http://localhost:3000/js/phase530_visible_panels_bridge.js -o /tmp/phase719_served_bridge.js

grep -nE "Recovery Artifact|Execution Plan|Completion Summary|Needs Review|Actionable|Rendered Preview" /tmp/phase719_served_bridge.js | head -30 || true

echo ""

echo "[3] Syntax check"

node --check public/js/phase530_visible_panels_bridge.js

echo ""

echo "===== COMPLETE ====="

