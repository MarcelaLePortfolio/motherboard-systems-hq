
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="multiple-package-lineage-inspection.txt"

FILES=(

  "docs/governance/COLLABORATION_AND_PACKAGE_LIFECYCLE.md"

  "docs/governance/CANONICAL_PACKAGE_SPECIFICATION.md"

  "docs/governance/MATILDA_INTERPRETATION_LIFECYCLE_RECONCILIATION.md"

  "docs/governance/CANONICAL_DELEGATION_SPECIFICATION.md"

)

{

  echo "=================================================="

  echo "MULTIPLE PACKAGE LINEAGE INSPECTION"

  echo "=================================================="

  echo

  for file in "${FILES[@]}"; do

    echo

    echo "=================================================="

    echo "$file"

    echo "=================================================="

    if [ -f "$file" ]; then

      grep -niE "multiple Packages|Package Comparison|approved interpretation|distinct approved interpretation|IEL|lineage|derived from|specific IEL state|Package version" "$file" || true

    else

      echo "MISSING: $file"

    fi

  done

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

