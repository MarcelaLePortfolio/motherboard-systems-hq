
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="iel-package-relationship-inspection.txt"

FILES=(

  "docs/governance/MATILDA_INTERPRETATION_LIFECYCLE_RECONCILIATION.md"

  "docs/governance/matilda-package-contract.md"

  "docs/governance/CANONICAL_PACKAGE_SPECIFICATION.md"

  "docs/governance/COLLABORATION_AND_PACKAGE_LIFECYCLE.md"

)

{

  echo "=================================================="

  echo "IEL / PACKAGE RELATIONSHIP INSPECTION"

  echo "=================================================="

  echo

  for file in "${FILES[@]}"; do

    echo

    echo "=================================================="

    echo "$file"

    echo "=================================================="

    if [ -f "$file" ]; then

      grep -niE "IEL|Draft Package|Package|derived from|future evidence|reconcile|reconciliation|lifecycle|interpretation" "$file" || true

    else

      echo "MISSING: $file"

    fi

  done

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

