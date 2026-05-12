
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

echo "===== PHASE 719 CARD HIERARCHY ANCHOR INSPECTION ====="

echo ""

echo "[1] Status / triage / explanation anchors"

grep -nE "status=|triageLabel|explanation|Detailed telemetry|summary|details" "$TARGET" | head -50 || true

echo ""

echo "[2] Current repo status"

git status --short

echo ""

echo "===== INSPECTION COMPLETE ====="

git add PHASE719_CARD_HIERARCHY_ANCHOR_INSPECTION.sh

git commit -m "Phase 719: inspect card hierarchy anchors"

git push origin dev

