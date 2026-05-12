
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

echo "===== PHASE 719 INSPECT INLINE RENDER WINDOW ====="

nl -ba "$TARGET" | sed -n '180,225p'

echo ""

echo "[status]"

git status --short

git add PHASE719_INSPECT_INLINE_RENDER_WINDOW.sh

git commit -m "Phase 719: inspect inline render window"

git push origin dev

