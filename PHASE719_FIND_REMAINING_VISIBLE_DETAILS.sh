
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 FIND REMAINING VISIBLE DETAILS ====="

echo ""

echo "[1] Repo status"

git status --short

echo ""

echo "[2] Search all served frontend files for visible task detail renderers"

grep -RInE "Status:|Updated:|details=|explanation_preview|summary\\.status|summary\\.updated|taskSummary\\(|renderRecentTasks|refreshTasks|recentTasks" \

  public/js public/*.html \

  --exclude="*.bak*" \

  2>/dev/null | head -200 || true

echo ""

echo "[3] Search served dashboard HTML from runtime"

TMP_HTML="$(mktemp)"

curl -fsS http://localhost:3000 > "$TMP_HTML"

grep -nE "Status:|Updated:|details=|explanation_preview|summary\\.status|summary\\.updated|taskSummary\\(|renderRecentTasks|refreshTasks|recentTasks" "$TMP_HTML" | head -120 || true

rm -f "$TMP_HTML"

echo ""

echo "===== TRACE COMPLETE ====="

git add PHASE719_FIND_REMAINING_VISIBLE_DETAILS.sh

git commit -m "Phase 719: trace remaining visible details renderer"

git push origin dev

