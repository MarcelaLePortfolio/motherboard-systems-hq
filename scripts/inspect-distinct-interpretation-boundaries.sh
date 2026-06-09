
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="distinct-interpretation-boundaries.txt"

FILES=(

  "docs/governance/COLLABORATION_AND_PACKAGE_LIFECYCLE.md"

  "docs/governance/CANONICAL_PACKAGE_SPECIFICATION.md"

  "docs/governance/matilda-package-contract.md"

  "docs/governance/MATILDA_INTERPRETATION_LIFECYCLE_RECONCILIATION.md"

)

{

  echo "=================================================="

  echo "DISTINCT INTERPRETATION BOUNDARY INSPECTION"

  echo "=================================================="

  echo

  for file in "${FILES[@]}"; do

    echo

    echo "=================================================="

    echo "$file"

    echo "=================================================="

    if [ -f "$file" ]; then

      grep -niE "intent|meaning|understanding|scope|assumption|artifact|outcome|interpretation|distinct approved interpretation|approved interpretation|Package Comparison|reconciliation|materially" "$file" || true

    else

      echo "MISSING: $file"

    fi

  done

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

