
#!/usr/bin/env bash

set -euo pipefail

echo "VERIFYING RECONCILED GOVERNANCE ARTIFACTS"

echo "Branch:"

git branch --show-current

echo

echo "Latest commits:"

git log --oneline -12

echo

echo "Governance docs:"

find docs/governance -maxdepth 2 -type f | sort

echo

echo "Searching reconciled lifecycle / package / preview / validation references:"

grep -RInE "Package|package preview|Package Preview|Preview|Delegation|Governance Validation|Envelope|Raw Evidence|IEL|reconciliation" docs/governance | sed -n '1,260p'

echo

echo "Targeted file excerpts:"

while IFS= read -r file; do

  if [ -f "$file" ]; then

    echo

    echo "===== $file ====="

    sed -n '1,220p' "$file"

  else

    echo

    echo "MISSING: $file"

  fi

done << 'FILES'

docs/governance/MATILDA_INTERPRETATION_LIFECYCLE_RECONCILIATION.md

docs/governance/MATILDA_COLLABORATION_MODE_V2_EVIDENCE_LEDGER.md

docs/governance/CANONICAL_PACKAGE_SPECIFICATION.md

docs/governance/CANONICAL_DELEGATION_SPECIFICATION.md

docs/governance/CANONICAL_ENVELOPE_SPECIFICATION.md

docs/governance/GOVERNANCE_VALIDATION_CHARTER.md

docs/governance/PREVIEW_WRAPPER_CORRIDOR_RECONCILIATION.md

FILES

echo

echo "PASS: Reconciled governance artifact verification completed"

