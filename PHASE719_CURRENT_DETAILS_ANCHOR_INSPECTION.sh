
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

echo "===== PHASE 719 CURRENT DETAILS ANCHOR INSPECTION ====="

echo ""

grep -nE "metaLines|details=|explanation|Inspect details|Outcome available|rawLine|line" "$TARGET" | head -80 || true

echo ""

echo "[status]"

git status --short

echo ""

echo "===== INSPECTION COMPLETE ====="

git add PHASE719_CURRENT_DETAILS_ANCHOR_INSPECTION.sh

git commit -m "Phase 719: inspect current details anchors"

git push origin dev

