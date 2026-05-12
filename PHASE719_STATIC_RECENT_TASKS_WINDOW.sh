
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

echo "===== PHASE 719 STATIC RECENT TASKS WINDOW ====="

echo ""

nl -ba "$TARGET" | sed -n '20,90p'

echo ""

echo "===== WINDOW COMPLETE ====="

git add PHASE719_STATIC_RECENT_TASKS_WINDOW.sh

git commit -m "Phase 719: inspect static recent tasks shell"

git push origin dev

