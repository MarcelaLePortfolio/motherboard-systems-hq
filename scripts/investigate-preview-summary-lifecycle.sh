
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="preview-summary-lifecycle-investigation.txt"

FILES=(

  "docs/governance/COLLABORATION_AND_PACKAGE_LIFECYCLE.md"

  "docs/governance/CANONICAL_PACKAGE_SPECIFICATION.md"

  "docs/governance/MATILDA_INTERPRETATION_LIFECYCLE_RECONCILIATION.md"

  "docs/governance/matilda-package-contract.md"

  "docs/governance/GOVERNANCE_LIFECYCLE_STATE_MODEL.md"

  "docs/governance/milestone-6-lifecycle-reconciliation-finding.md"

)

{

  echo "=================================================="

  echo "PREVIEW SUMMARY LIFECYCLE INVESTIGATION"

  echo "=================================================="

  echo

  echo "Branch: $(git branch --show-current)"

  echo

  echo "Latest Governance Commits:"

  git log --oneline -20

  echo

  echo "=================================================="

  echo "SEARCH: preview summary references"

  echo "=================================================="

  grep -RInE "preview summary|Preview Summary|preview-summary|package preview|Package Preview|Preview Artifact|natural language.*summary|summary.*package|writeup|write-up" docs/governance . \

    --exclude-dir=node_modules \

    --exclude-dir=.git \

    --exclude="*.log" || true

  echo

  echo "=================================================="

  echo "SEARCH: draft/canonical package lifecycle references"

  echo "=================================================="

  grep -RInE "Draft Package|Canonical Package|Package|Delegation|Governance Validation|Envelope|Preview" docs/governance \

    --exclude="*.log" || true

  echo

  echo "=================================================="

  echo "TARGETED FILES"

  echo "=================================================="

  for file in "${FILES[@]}"; do

    echo

    echo "--------------------------------------------------"

    echo "$file"

    echo "--------------------------------------------------"

    if [ -f "$file" ]; then

      sed -n '1,420p' "$file"

    else

      echo "MISSING: $file"

    fi

  done

} | tee "$OUTPUT"

echo

echo "Investigation complete."

echo "Output written to: $OUTPUT"

