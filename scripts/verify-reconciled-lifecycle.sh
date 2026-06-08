
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="reconciled-lifecycle-review.txt"

FILES=(

  "docs/governance/COLLABORATION_AND_PACKAGE_LIFECYCLE.md"

  "docs/governance/CANONICAL_PACKAGE_SPECIFICATION.md"

  "docs/governance/CANONICAL_DELEGATION_SPECIFICATION.md"

  "docs/governance/GOVERNANCE_VALIDATION_CHARTER.md"

  "docs/governance/GOVERNANCE_VALIDATION_SPECIFICATION.md"

  "docs/governance/CANONICAL_ENVELOPE_SPECIFICATION.md"

  "docs/governance/MATILDA_INTERPRETATION_LIFECYCLE_RECONCILIATION.md"

  "docs/governance/matilda-package-contract.md"

)

{

  echo "=================================================="

  echo "RECONCILED LIFECYCLE REVIEW"

  echo "=================================================="

  echo

  echo "Branch: $(git branch --show-current)"

  echo

  echo "Latest Governance Commits:"

  git log --oneline -15

  echo

  echo "Relevant lifecycle references:"

  grep -RInE "Package Preview|package preview|Preview Artifact|Package|Delegation|Governance Validation|Envelope|Raw Evidence|IEL|reconciliation|lifecycle" docs/governance || true

  echo

  for file in "${FILES[@]}"; do

    echo

    echo "=================================================="

    echo "$file"

    echo "=================================================="

    if [ -f "$file" ]; then

      sed -n '1,320p' "$file"

    else

      echo "MISSING: $file"

    fi

    echo

  done

} | tee "$OUTPUT"

echo

echo "Review complete."

echo "Output written to: $OUTPUT"

