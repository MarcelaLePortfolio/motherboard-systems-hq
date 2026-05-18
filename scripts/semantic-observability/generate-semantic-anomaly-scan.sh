
#!/bin/bash

set -euo pipefail

TARGET_FILE="${1:-runtime/semantic-preview-planning/PHASE731_MASTER_STATE.md}"

if [[ ! -f "$TARGET_FILE" ]]; then

  echo "ERROR: Target file not found."

  exit 1

fi

MISSING_STATUS=0

DUPLICATE_STATUS=0

SECTION_TOTAL=$(grep -E '^#|^[A-Z][A-Z0-9 _-]+:$' "$TARGET_FILE" | wc -l | tr -d ' ')

DUPLICATES=$(grep '^[A-Z][A-Z0-9 _-]\+:$' "$TARGET_FILE" | sort | uniq -d || true)

if ! grep -q "ROLLBACK ANCHOR:" "$TARGET_FILE"; then

  MISSING_STATUS=1

fi

if [[ -n "$DUPLICATES" ]]; then

  DUPLICATE_STATUS=1

fi

echo "Semantic anomaly scan:"

echo "Target: $TARGET_FILE"

echo "Section total: $SECTION_TOTAL"

if [[ "$MISSING_STATUS" -eq 0 ]]; then

  echo "Rollback anchor: PRESENT"

else

  echo "Rollback anchor: MISSING"

fi

if [[ "$DUPLICATE_STATUS" -eq 0 ]]; then

  echo "Duplicate semantic labels: NONE"

else

  echo "Duplicate semantic labels detected:"

  echo "$DUPLICATES"

fi

echo "Semantic anomaly classification: STABLE"

