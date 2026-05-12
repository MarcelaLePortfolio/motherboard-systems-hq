
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

echo "===== PHASE 719 DUPLICATE RECENT TASKS INSPECTION ====="

echo ""

echo "[1] Recent Tasks render anchors"

grep -nE "Recent Tasks|RECENT TASKS|recentTasks|renderRecent|tasks.map|taskList|innerHTML|appendChild|status=|Updated:" "$TARGET" | head -80 || true

echo ""

echo "[2] Lifecycle card anchors"

grep -nE "Operator actions|Inspect details|Inspect trace|Inspect logs|triageLabel|phase718TaskTitleByKey" "$TARGET" | head -80 || true

echo ""

echo "[3] Repo status"

git status --short

echo ""

echo "===== INSPECTION COMPLETE ====="

git add PHASE719_DUPLICATE_RECENT_TASKS_INSPECTION.sh

git commit -m "Phase 719: inspect duplicate recent tasks renderers"

git push origin dev

