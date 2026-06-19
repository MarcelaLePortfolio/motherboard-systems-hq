
#!/usr/bin/env bash

set -euo pipefail

REPORT="governance-approval-core-files-report.txt"

FILES=(

  docs/contracts/PREVIEW_APPROVAL_RECONCILIATION_FINDING.md

  planning-vs-execution-authority-repo-finding.txt

  governance-validation-repo-answer.txt

  reviewable-planning-artifact-ui-finding.txt

  governed-planning-preview-fit-finding.txt

  docs/contracts/GOVERNED_PLANNING_ARTIFACT_BUNDLE.md

  server/execution/build-governed-planning-artifact-bundle.mjs

  server/execution/build-approval-artifact.mjs

  server/execution/execution-approval-gate.mjs

  docs/phase743-execution-bridge/MATILDA_APPROVAL_CONTRACT.md

)

{

  echo "GOVERNANCE APPROVAL CORE FILES INSPECTION"

  echo

  echo "--- current head ---"

  git log --oneline -6

  echo

  for f in "${FILES[@]}"; do

    echo

    echo "=================================================================="

    echo "FILE: $f"

    echo "=================================================================="

    if [ -f "$f" ]; then

      sed -n '1,220p' "$f"

    else

      echo "MISSING: $f"

    fi

  done

  echo

  echo "=================================================================="

  echo "FOCUSED CROSS-FILE LINES"

  echo "=================================================================="

  rg -n -i "approve|approval|preview|planning artifact|execution authorization|execution approval|governance validation|reviewable|artifact bundle|authority" "${FILES[@]}" 2>/dev/null || true

} | tee "$REPORT"

echo

echo "Report written to: $REPORT"

git add inspect-governance-approval-core-files.sh "$REPORT"

git commit -m "Inspect governance approval core files" || true

git push

