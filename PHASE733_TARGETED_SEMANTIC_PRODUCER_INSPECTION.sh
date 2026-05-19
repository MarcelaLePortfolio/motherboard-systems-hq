
#!/bin/bash

set -euo pipefail

OUTPUT="PHASE733_TARGETED_SEMANTIC_PRODUCER_INSPECTION.txt"

: > "$OUTPUT"

for TARGET in \

  "server.ts" \

  "matilda_task_processor.ts" \

  "tasks.ts" \

  "routes/api/tasks.ts" \

  "routes/api/delegate.ts" \

  "routes/delegate.ts" \

  "routes/tasks.ts"

do

  {

    echo "=== TARGET: $TARGET ==="

    if [ -f "$TARGET" ]; then

      grep -nE "MB_SEMANTIC_ARTIFACT_V1|task_summary|actionable_outputs|evidence_notes|raw_markdown_fallback|artifact-preview|visual-artifact|compiler_options|execution_meta" "$TARGET" || true

    else

      echo "missing"

    fi

    echo

  } >> "$OUTPUT"

done

cat "$OUTPUT"

