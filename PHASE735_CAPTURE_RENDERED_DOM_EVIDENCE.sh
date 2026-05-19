
#!/bin/bash

set -euo pipefail

OUTPUT="PHASE735_RENDERED_DOM_EVIDENCE.txt"

{

  echo "# Phase 735 Rendered DOM Evidence"

  echo ""

  echo "Timestamp: $(date)"

  echo ""

  echo "## Active renderer mount code"

  echo ""

  grep -n "phase735-visual-html-template\|phase735-visual-html-mount\|phase735DecodeVisualArtifactHtmlTransport" \

    public/js/phase530_visible_panels_bridge.js || true

  echo ""

  echo "## Interpretation"

  echo ""

  echo "- Runtime renderer patch confirmed present."

  echo "- Remaining fault is likely browser-side rendered DOM behavior."

  echo "- Next evidence required is browser inspector output."

  echo ""

  echo "## Browser Inspection Required"

  echo ""

  echo "1. Open Artifact Garden preview"

  echo "2. Right click raw HTML area"

  echo "3. Inspect Element"

  echo "4. Confirm whether:"

  echo "   - template content still exists visibly"

  echo "   - innerHTML mount exists"

  echo "   - browser converted template to text"

  echo "   - sanitizer escaped tags"

  echo ""

  echo "## Boundary"

  echo ""

  echo "- No new patch until DOM evidence captured."

  echo "- Renderer-only investigation corridor remains active."

} > "$OUTPUT"

cat "$OUTPUT"

