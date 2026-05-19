
#!/bin/bash

set -euo pipefail

OUTPUT="PHASE735_MODAL_RENDER_ASSIGNMENT_SCAN.txt"

{

  echo "# Phase 735 Modal Render Assignment Scan"

  echo ""

  grep -n "innerHTML.*phase719RenderMarkdownArtifactPreview\|phase719RenderMarkdownArtifactPreview(markdown)\|preview-body\|body.innerHTML" public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "## nearby modal function"

  grep -n "async function phase719OpenPreviewModal" -A180 public/js/phase530_visible_panels_bridge.js || true

} > "$OUTPUT"

cat "$OUTPUT"

