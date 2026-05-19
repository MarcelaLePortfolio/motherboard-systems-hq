
#!/bin/bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

OUTPUT="PHASE733_RENDERER_TARGET_CAPTURE.txt"

{

  echo "=== Phase 733 Targeted Renderer Capture ==="

  echo "Target: $TARGET"

  echo

  echo "=== File Exists ==="

  test -f "$TARGET" && echo "YES" || echo "NO"

  echo

  echo "=== Matching Lines ==="

  grep -nE "artifact|preview|semantic|innerHTML|sanitize|markdown|\\\\n|replace|render|modal" "$TARGET" || true

} > "$OUTPUT"

cat "$OUTPUT"

