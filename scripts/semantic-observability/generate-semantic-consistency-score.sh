
#!/bin/bash

set -euo pipefail

TARGET_FILE="${1:-runtime/semantic-preview-planning/PHASE731_SEAL.md}"

if [[ ! -f "$TARGET_FILE" ]]; then

  echo "ERROR: Target file not found."

  exit 1

fi

SECTION_COUNT=$(grep -E '^#|^[A-Z][A-Z0-9 _-]+:$' "$TARGET_FILE" | wc -l | tr -d ' ')

UPPERCASE_LABEL_COUNT=$(grep '^[A-Z][A-Z0-9 _-]\+:$' "$TARGET_FILE" | wc -l | tr -d ' ')

SCORE=$((SECTION_COUNT * 10 + UPPERCASE_LABEL_COUNT * 5))

echo "Semantic consistency scoring:"

echo "Target: $TARGET_FILE"

echo "Section count: $SECTION_COUNT"

echo "Uppercase label count: $UPPERCASE_LABEL_COUNT"

echo "Consistency score: $SCORE"

