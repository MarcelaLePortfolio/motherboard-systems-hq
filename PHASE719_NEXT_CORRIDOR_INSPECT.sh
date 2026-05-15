
#!/bin/bash

set -euo pipefail

echo "===== PHASE 719 NEXT CORRIDOR INSPECT ====="

echo ""

echo "[1] Locate artifact preview endpoint usage"

grep -n "/artifact-preview\\|phase719OpenPreviewModal\\|phase719RenderMarkdownArtifactPreview" public/js/phase530_visible_panels_bridge.js || true

echo ""

echo "[2] Locate preview modal body renderer"

grep -n "phase719-preview-body\\|body.innerHTML" public/js/phase530_visible_panels_bridge.js || true

echo ""

echo "[3] Inspect current artifact API routes"

find server -type f | grep -E "task|artifact|preview" | sort || true

echo ""

echo "[4] Search artifact preview backend implementation"

grep -Rni "artifact-preview" server routes . 2>/dev/null | head -40 || true

echo ""

echo "[5] Runtime validation"

node --check public/js/phase530_visible_panels_bridge.js

echo ""

echo "===== COMPLETE ====="

