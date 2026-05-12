
#!/usr/bin/env bash

set -euo pipefail

OUT_DIR="phase719_dom_inspection"

HTML_FILE="$OUT_DIR/dashboard.html"

mkdir -p "$OUT_DIR"

echo "===== PHASE 719 RECENT TASKS DOM SOURCE INSPECTION ====="

echo ""

curl -fsS http://localhost:3000 > "$HTML_FILE"

echo "[1] Dashboard HTML Recent Tasks anchors"

grep -nE "recentTasks|Recent Tasks|status=|Updated:|Inspect details|phase530_visible_panels_bridge" "$HTML_FILE" | head -80 || true

echo ""

echo "[2] Script references"

grep -oE 'src="[^"]+"' "$HTML_FILE" | sed 's/src=//g' | head -40 || true

echo ""

echo "[3] Saved dashboard HTML"

echo "$HTML_FILE"

echo ""

echo "===== INSPECTION COMPLETE ====="

git add PHASE719_RECENT_TASKS_DOM_SOURCE_INSPECTION.sh "$OUT_DIR"

git commit -m "Phase 719: inspect recent tasks DOM source"

git push origin dev

