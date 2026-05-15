
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

echo "===== PHASE 720 FRONTEND RENDER FUNCTION INSPECTION ====="

echo ""

echo "[1] Current HEAD"

git log --oneline --decorate -5

echo ""

echo "[2] Working tree"

git status --short

echo ""

echo "[3] Escape function location"

grep -n "function phase719EscapePreviewHtml" "$TARGET" || true

echo ""

echo "[4] Markdown render function location"

grep -n "function phase719RenderMarkdownArtifactPreview" "$TARGET" || true

echo ""

echo "[5] Relevant artifact preview block"

START=$(grep -n "function phase719EscapePreviewHtml" "$TARGET" | head -1 | cut -d: -f1)

END=$(grep -n "async function phase719OpenPreviewModal" "$TARGET" | head -1 | cut -d: -f1)

if [ -n "${START:-}" ] && [ -n "${END:-}" ]; then

  sed -n "${START},${END}p" "$TARGET"

else

  echo "Could not determine block boundaries."

fi

echo ""

echo "===== INSPECTION COMPLETE ====="

