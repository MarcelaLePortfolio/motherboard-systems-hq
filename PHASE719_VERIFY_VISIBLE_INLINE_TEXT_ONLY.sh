
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 VERIFY VISIBLE INLINE TEXT ONLY ====="

TARGET="public/js/phase530_visible_panels_bridge.js"

echo ""

echo "[1] Served updated/target anchors"

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -nE "updated=|target=" || true

echo ""

echo "[2] Local render window"

nl -ba "$TARGET" | sed -n '190,225p'

echo ""

echo "[3] Repo status"

git status --short

echo ""

echo "===== VERIFY COMPLETE ====="

git add PHASE719_VERIFY_VISIBLE_INLINE_TEXT_ONLY.sh

git commit -m "Phase 719: verify visible inline text anchors"

git push origin dev

