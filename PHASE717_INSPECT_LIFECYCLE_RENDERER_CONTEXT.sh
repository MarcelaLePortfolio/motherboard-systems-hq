
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 717 LIFECYCLE RENDERER CONTEXT INSPECTION ====="

echo ""

echo "[1] Current checkpoint"

git status --short

git log --oneline --decorate -3

echo ""

echo "[2] Renderer context around lifecycle controls"

nl -ba public/js/phase530_visible_panels_bridge.js | sed -n '60,115p'

echo ""

echo "[3] Existing click/action helpers in renderer"

grep -n "addEventListener\|onclick\|fetch(\|delegate-task\|api/delegate-task\|button" public/js/phase530_visible_panels_bridge.js | head -120

echo ""

echo "===== INSPECTION COMPLETE ====="

