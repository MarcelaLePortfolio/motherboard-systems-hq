
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

grep -RIn \

  -e "Package" \

  -e "package preview" \

  -e "Package Preview" \

  -e "Preview" \

  -e "Delegation" \

  -e "Governance Validation" \

  -e "Envelope" \

  -e "Raw Evidence" \

  -e "IEL" \

  -e "reconciliation" \

  docs/governance | sed -n '1,260p'

echo

echo "Targeted file excerpts:"

for file in \

  docs/governance/MATILDA_INTERPRETATION_LIFECYCLE_RECONCILIATION.md \

  docs/governance/MATILDA_COLLABORATION_MODE_V2_EVIDENCE_LEDGER.md \

  docs/governance/CANONICAL_PACKAGE_SPECIFICATION.md \

  docs/governance/CANONICAL_DELEGATION_SPECIFICATION.md \

  docs/governance/CANONICAL_ENVELOPE_SPECIFICATION.md \

  docs/governance/GOVERNANCE_VALIDATION_CHARTER.md \

  docs/governance/PREVIEW_WRAPPER_CORRIDOR_RECONCILIATION.md

do

  if [ -f "$file" ]; then

    echo

    echo "===== $file ====="

    sed -n '1,220p' "$file"

  else

    echo

    echo "MISSING: $file"

  fi

done

