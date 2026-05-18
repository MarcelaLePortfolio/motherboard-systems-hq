
#!/bin/bash

set -euo pipefail

EXPORT_ROOT="runtime/semantic-preview-planning/exports"

INDEX_FILE="runtime/semantic-preview-planning/export-index.md"

mkdir -p "$EXPORT_ROOT"

echo "# Semantic Export Index" > "$INDEX_FILE"

echo "" >> "$INDEX_FILE"

find "$EXPORT_ROOT" -name "semantic-preview-snapshot.json" | sort | while read -r FILE; do

  TIMESTAMP=$(basename "$(dirname "$FILE")")

  echo "- $TIMESTAMP :: $FILE" >> "$INDEX_FILE"

done

echo ""

echo "Semantic export index generated:"

echo "$INDEX_FILE"

