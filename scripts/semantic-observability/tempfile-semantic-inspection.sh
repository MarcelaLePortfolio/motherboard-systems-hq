
#!/bin/bash

set -euo pipefail

TARGET_FILE="${1:-runtime/semantic-preview-planning/PHASE731_SEAL.md}"

if [[ ! -f "$TARGET_FILE" ]]; then

  echo "ERROR: Target file not found."

  exit 1

fi

TMP_OUTPUT=$(mktemp)

echo "Generating semantic inspection snapshot..."

{

  echo "FILE: $TARGET_FILE"

  echo ""

  echo "SECTION HEADERS:"

  grep '^#' "$TARGET_FILE" || true

  echo ""

  echo "UPPER LABEL HEADERS:"

  grep '^[A-Z][A-Z0-9 _-]\+:$' "$TARGET_FILE" || true

} > "$TMP_OUTPUT"

echo "Inspection snapshot created:"

echo "$TMP_OUTPUT"

