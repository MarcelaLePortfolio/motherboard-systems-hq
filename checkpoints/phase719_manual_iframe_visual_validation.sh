
#!/bin/bash

set -e

echo "===== PHASE 719 MANUAL IFRAME VISUAL VALIDATION ====="

echo ""

echo "[1] Confirm stable checkpoint"

git log --oneline --decorate -5

echo ""

echo "[2] Confirm working tree"

git status --short

echo ""

echo "[3] Confirm iframe renderer still present"

grep -n "phase719RenderArtifactIframePreview\|phase719RenderMarkdownArtifactPreview\|sandbox=\"\"" public/js/phase530_visible_panels_bridge.js

echo ""

echo "[4] Open dashboard"

open http://localhost:3000 || true

echo ""

echo "MANUAL CHECK REQUIRED:"

echo "1. Click Preview on a completed artifact-backed task."

echo "2. Confirm preview opens inside the modal."

echo "3. Confirm artifact content is visible inside the iframe."

echo "4. Confirm Close works."

echo "5. Confirm page remains responsive."

echo "6. Confirm retry/requeue controls still appear normally."

echo ""

echo "If all pass, run the seal command next."

echo "If any fail, do not patch forward; revert iframe renderer only."

echo ""

echo "===== MANUAL VALIDATION PROMPT COMPLETE ====="

