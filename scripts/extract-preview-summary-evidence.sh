
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="preview-summary-evidence-extract.txt"

COMMITS=(

  "77f5ed4c"

  "fb58d50c"

  "97c090d0"

  "5a6e848f"

  "1603584d"

)

FILES=(

  "docs/governance/COLLABORATION_AND_PACKAGE_LIFECYCLE.md"

  "docs/governance/CANONICAL_PACKAGE_SPECIFICATION.md"

  "docs/governance/GOVERNANCE_LIFECYCLE_STATE_MODEL.md"

  "docs/governance/matilda-package-contract.md"

  "docs/governance/milestone-6-lifecycle-reconciliation-finding.md"

  "reconciled-lifecycle-review.txt"

  "preview-summary-lifecycle-investigation.txt"

)

{

  echo "=================================================="

  echo "PREVIEW SUMMARY EVIDENCE EXTRACT"

  echo "=================================================="

  echo

  echo "Branch: $(git branch --show-current)"

  echo

  echo "Latest Governance Commits:"

  git log --oneline -25

  echo

  echo "=================================================="

  echo "HIGH-SIGNAL SEARCHES"

  echo "=================================================="

  echo

  echo "--- package preview / preview summary ---"

  grep -RInEi \

    --exclude-dir=.git \

    --exclude-dir=node_modules \

    --exclude-dir=backups \

    --exclude-dir=_dashboard_candidate_previews \

    --exclude="*.log" \

    "package preview|preview summary|package summary|summary preview|preview artifact|preview write|natural language|plain language|review summary|user review" \

    docs/governance . || true

  echo

  echo "--- lifecycle / package / preview proximity ---"

  grep -RInEi \

    --exclude-dir=.git \

    --exclude-dir=node_modules \

    --exclude-dir=backups \

    --exclude-dir=_dashboard_candidate_previews \

    --exclude="*.log" \

    "draft package|canonical package|package.*preview|preview.*package|package.*review|review.*package|package.*summary|summary.*package|delegation.*preview|preview.*delegation" \

    docs/governance . || true

  echo

  echo "=================================================="

  echo "FOCUSED COMMITS"

  echo "=================================================="

  for commit in "${COMMITS[@]}"; do

    echo

    echo "--------------------------------------------------"

    echo "COMMIT $commit"

    echo "--------------------------------------------------"

    git show --stat --oneline "$commit" || true

    echo

    git show --name-only --format=fuller "$commit" || true

  done

  echo

  echo "=================================================="

  echo "TARGETED DOCUMENT EXCERPTS"

  echo "=================================================="

  for file in "${FILES[@]}"; do

    echo

    echo "--------------------------------------------------"

    echo "$file"

    echo "--------------------------------------------------"

    if [ -f "$file" ]; then

      grep -nEi "preview summary|package preview|preview|summary|natural language|Draft Package|Canonical Package|Delegation|Package" "$file" || true

    else

      echo "MISSING: $file"

    fi

  done

} | tee "$OUTPUT"

echo

echo "Evidence extraction complete."

echo "Output written to: $OUTPUT"

