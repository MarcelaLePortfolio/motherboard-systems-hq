
#!/bin/bash

set -euo pipefail

EXPORT_ROOT="runtime/semantic-preview-planning/exports"

LATEST_TWO=$(find "$EXPORT_ROOT" -name "semantic-preview-snapshot.json" | sort | tail -n 2)

COUNT=$(echo "$LATEST_TWO" | wc -l | tr -d ' ')

if [[ "$COUNT" -lt 2 ]]; then

  echo "ERROR: At least two exports are required for comparison."

  exit 1

fi

FIRST=$(echo "$LATEST_TWO" | head -n 1)

SECOND=$(echo "$LATEST_TWO" | tail -n 1)

echo "Comparing:"

echo "$FIRST"

echo "$SECOND"

if diff -q "$FIRST" "$SECOND" >/dev/null; then

  echo "Comparison result: IDENTICAL"

else

  echo "Comparison result: DIFFERENT"

fi

