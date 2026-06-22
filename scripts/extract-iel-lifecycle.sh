
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="iel-lifecycle-extract.txt"

FILE="docs/governance/MATILDA_INTERPRETATION_LIFECYCLE_RECONCILIATION.md"

{

  echo "=================================================="

  echo "IEL LIFECYCLE EXTRACT"

  echo "=================================================="

  echo

  if [ -f "$FILE" ]; then

    sed -n '1,320p' "$FILE"

  else

    echo "MISSING: $FILE"

  fi

} | tee "$OUTPUT"

echo

echo "Extraction complete."

echo "Output written to: $OUTPUT"

