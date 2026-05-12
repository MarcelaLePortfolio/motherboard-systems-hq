
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 MINIMAL DETAILS TRACE ====="

echo ""

echo "[1] Active frontend files still rendering Status/Updated"

grep -RIl 'Status: " + summary.status' public/js public/*.html 2>/dev/null || true

echo ""

echo "[2] Active frontend files still rendering explanation/details"

grep -RIl 'explanation_preview\|details=' public/js public/*.html 2>/dev/null || true

echo ""

echo "[3] Runtime-served dashboard references"

TMP_HTML="$(mktemp)"

curl -fsS http://localhost:3000 > "$TMP_HTML"

grep -nE 'phase565_recent_tasks_wire|phase530_visible_panels_bridge|task-completion' "$TMP_HTML" || true

rm -f "$TMP_HTML"

echo ""

echo "===== TRACE COMPLETE ====="

git add PHASE719_FIND_REMAINING_VISIBLE_DETAILS_MINIMAL.sh

git commit -m "Phase 719: minimal remaining details trace"

git push origin dev

