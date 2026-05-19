
#!/bin/bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

OUTPUT="PHASE733_RENDERER_SLICES_CAPTURE.txt"

{

  echo "=== Phase 733 Renderer Slice Capture ==="

  echo "Target: $TARGET"

  echo

  echo "=== Slice A: Semantic extraction + visual card renderer, lines 780-1128 ==="

  sed -n '780,1128p' "$TARGET"

  echo

  echo "=== Slice B: Visual artifact candidate + preview stack, lines 1180-1488 ==="

  sed -n '1180,1488p' "$TARGET"

} > "$OUTPUT"

cat "$OUTPUT"

