
#!/bin/bash

set -euo pipefail

LATEST_TWO=$(find runtime/semantic-preview-planning/exports -name "semantic-preview-snapshot.json" | sort | tail -n 2)

COUNT=$(echo "$LATEST_TWO" | wc -l | tr -d ' ')

if [[ "$COUNT" -lt 2 ]]; then

  echo "ERROR: At least two exports required for drift detection."

  exit 1

fi

FIRST=$(echo "$LATEST_TWO" | head -n 1)

SECOND=$(echo "$LATEST_TWO" | tail -n 1)

TMP_DIFF=$(mktemp)

diff "$FIRST" "$SECOND" > "$TMP_DIFF" || true

echo "Semantic drift inspection:"

echo "Baseline: $FIRST"

echo "Candidate: $SECOND"

if [[ -s "$TMP_DIFF" ]]; then

  echo "Drift status: DIFFERENCES DETECTED"

  echo "Diff snapshot:"

  cat "$TMP_DIFF"

else

  echo "Drift status: NO DIFFERENCES DETECTED"

fi

rm -f "$TMP_DIFF"

