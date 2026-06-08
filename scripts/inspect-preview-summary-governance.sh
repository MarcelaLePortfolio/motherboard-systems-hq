
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="preview-summary-governance-inspection.txt"

FILES=(

"docs/governance/COLLABORATION_AND_PACKAGE_LIFECYCLE.md"

"docs/governance/CANONICAL_PACKAGE_SPECIFICATION.md"

"docs/governance/GOVERNANCE_LIFECYCLE_STATE_MODEL.md"

"docs/governance/matilda-package-contract.md"

"docs/governance/milestone-6-lifecycle-reconciliation-finding.md"

"docs/governance/milestone-6-outcome-review-governance-contracts.md"

"docs/contracts/PREVIEW_APPROVAL_RECONCILIATION_FINDING.md"

)

{

echo "=================================================="

echo "PREVIEW SUMMARY GOVERNANCE INSPECTION"

echo "=================================================="

for file in "${FILES[@]}"; do

echo

echo "=================================================="

echo "$file"

echo "=================================================="

if [ -f "$file" ]; then

grep -niE "preview|summary|review|package|delegation|approval" "$file" || true

else

echo "MISSING: $file"

fi

done

} | tee "$OUTPUT"

echo

echo "Inspection complete."

echo "Output written to: $OUTPUT"

