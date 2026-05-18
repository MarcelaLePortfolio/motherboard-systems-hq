
#!/bin/bash

set -euo pipefail

TARGET_FILE="${1:-runtime/semantic-preview-planning/PHASE731_CHECKPOINT.md}"

if [[ ! -f "$TARGET_FILE" ]]; then

  echo "ERROR: Target file not found."

  exit 1

fi

echo "Inspecting semantic section structure:"

echo "$TARGET_FILE"

SECTION_COUNT=$(grep -E '^#|^[A-Z][A-Z0-9 _-]+:$' "$TARGET_FILE" | wc -l | tr -d ' ')

echo "Detected section structures: $SECTION_COUNT"

if [[ "$SECTION_COUNT" -lt 3 ]]; then

  echo "WARNING: Low section count detected."

  exit 1

fi

echo "Semantic section structure verification: PASS"

