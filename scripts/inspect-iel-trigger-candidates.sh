
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="iel-trigger-candidates.txt"

FILES=(

  "docs/governance/MATILDA_INTERPRETATION_LIFECYCLE_RECONCILIATION.md"

  "docs/governance/MATILDA_COLLABORATION_MODE_V2_EVIDENCE_LEDGER.md"

)

{

  echo "=================================================="

  echo "IEL TRIGGER CANDIDATE INSPECTION"

  echo "=================================================="

  echo

  for file in "${FILES[@]}"; do

    echo

    echo "=================================================="

    echo "$file"

    echo "=================================================="

    if [ -f "$file" ]; then

      grep -niE "event|observation|capture|preserve|evidence|change|understanding|interpretation" "$file" || true

    else

      echo "MISSING: $file"

    fi

  done

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

