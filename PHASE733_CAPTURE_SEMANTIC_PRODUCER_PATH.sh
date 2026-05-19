
#!/bin/bash

set -euo pipefail

OUTPUT="PHASE733_SEMANTIC_PRODUCER_PATH_CAPTURE.txt"

{

  echo "=== Phase 733 Semantic Producer Path Capture ==="

  echo

  echo "=== MB_SEMANTIC_ARTIFACT_V1 occurrences ==="

  grep -RIn "MB_SEMANTIC_ARTIFACT_V1" . \

    --exclude-dir=node_modules \

    --exclude-dir=.git \

    --exclude-dir=backups \

    2>/dev/null || true

  echo

  echo "=== semantic envelope / task_summary producer candidates ==="

  grep -RIn "task_summary\|actionable_outputs\|evidence_notes\|raw_markdown_fallback" worker src routes . \

    --exclude-dir=node_modules \

    --exclude-dir=.git \

    --exclude-dir=backups \

    2>/dev/null | head -160 || true

} > "$OUTPUT"

cat "$OUTPUT"

