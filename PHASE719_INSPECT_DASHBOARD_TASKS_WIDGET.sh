
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/dashboard-tasks-widget.js"

echo "===== PHASE 719 INSPECT DASHBOARD TASKS WIDGET ====="

echo ""

echo "[1] File existence"

ls -l "$TARGET"

echo ""

echo "[2] Relevant render anchors"

grep -nE 'recentTasks|Status:|Updated:|details=|summary|innerHTML|appendChild|taskSummary|render|mount|explanation' "$TARGET" | head -120 || true

echo ""

echo "[3] Focused render window"

nl -ba "$TARGET" | sed -n '1,260p'

echo ""

echo "===== INSPECTION COMPLETE ====="

git add PHASE719_INSPECT_DASHBOARD_TASKS_WIDGET.sh

git commit -m "Phase 719: inspect dashboard tasks widget"

git push origin dev

