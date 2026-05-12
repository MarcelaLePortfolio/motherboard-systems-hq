
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

OUT_DIR="phase719_visible_details_trace"

mkdir -p "$OUT_DIR"

echo "===== PHASE 719 TRACE VISIBLE DETAILS SOURCE ====="

echo ""

echo "[1] Search renderer for visible detail-related text"

grep -nE "details=|Details|Inspect details|Outcome available|explanation|summary|telemetry|logs|trace" "$TARGET" > "$OUT_DIR/renderer-grep.txt" || true

cat "$OUT_DIR/renderer-grep.txt"

echo ""

echo "[2] Fetch served JS"

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js > "$OUT_DIR/served-phase530.js"

echo ""

echo "[3] Search served JS for same anchors"

grep -nE "details=|Details|Inspect details|Outcome available|explanation|summary|telemetry|logs|trace" "$OUT_DIR/served-phase530.js" > "$OUT_DIR/served-grep.txt" || true

cat "$OUT_DIR/served-grep.txt"

echo ""

echo "[4] Save current dashboard HTML snapshot"

curl -fsS http://localhost:3000 > "$OUT_DIR/dashboard.html"

echo ""

echo "[5] Search dashboard HTML"

grep -nE "details=|Details|Inspect details|Outcome available|summary|telemetry|logs|trace" "$OUT_DIR/dashboard.html" | head -120 || true

echo ""

echo "[6] Repo status"

git status --short

echo ""

echo "===== TRACE COMPLETE ====="

git add PHASE719_TRACE_VISIBLE_DETAILS_SOURCE.sh "$OUT_DIR"

git commit -m "Phase 719: trace visible details source"

git push origin dev

