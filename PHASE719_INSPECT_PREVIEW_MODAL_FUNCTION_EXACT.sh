
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: INSPECT PREVIEW MODAL FUNCTION EXACT ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

TARGET="public/js/phase530_visible_panels_bridge.js"

OUT="checkpoints/PHASE719_PREVIEW_MODAL_FUNCTION_EXACT_INSPECTION.txt"

{

  echo "BRANCH"

  echo "$BRANCH"

  echo ""

  echo "HEAD"

  git log --oneline --decorate -5

  echo ""

  echo "PREVIEW MODAL FUNCTION LINES"

  nl -ba "$TARGET" | sed -n '740,835p'

  echo ""

  echo "PREVIEW MODAL MARKERS"

  grep -nE 'function phase719OpenPreviewModal|async function phase719OpenPreviewModal|phase719-preview-body|data-artifact-outcome|data-artifact-explanation|File content preview|artifact-preview|Loading rendered' "$TARGET" || true

  echo ""

  echo "SYNTAX"

  node --check "$TARGET" || true

  echo ""

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/health' || true

  echo ""

  echo "PREVIEW ROUTE SAMPLE"

  curl -i -s --max-time 10 'http://localhost:3000/api/tasks/t_3e163cb2-999d-4cdb-b618-baad85cff46c/artifact-preview' | head -n 80 || true

} | tee "$OUT"

git add PHASE719_INSPECT_PREVIEW_MODAL_FUNCTION_EXACT.sh

git add PHASE719_WIRE_PREVIEW_MODAL_TO_ARTIFACT_CONTENT.sh || true

git add "$OUT"

git commit -m "Phase 719: inspect exact preview modal function before fetch wiring"

git push origin "$BRANCH"

echo "===== PREVIEW MODAL FUNCTION INSPECTION COMPLETE ====="

