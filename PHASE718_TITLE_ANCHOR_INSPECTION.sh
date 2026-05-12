
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

echo "===== PHASE 718 TITLE ANCHOR INSPECTION ====="

echo ""

echo "[1] Title-related lines"

grep -nE "const title|task_title|Untitled|updated=|<h|font-size:16|font-weight" "$TARGET" | head -30 || true

echo ""

echo "[2] Current git status"

git status --short

echo ""

echo "===== INSPECTION COMPLETE ====="

git add PHASE718_TITLE_ANCHOR_INSPECTION.sh

git commit -m "Phase 718: inspect title normalization anchors"

git push origin dev

