
#!/usr/bin/env bash

set -euo pipefail

REPORT="governance-approval-evidence-report.txt"

COMMITS=(

  a19d2459

  e993b70c

  43ce1e3c

  453028df

  9908a0a5

  57e3cc2f

  34376f97

  effcdf4e

  a8ce5239

)

{

  echo "GOVERNANCE APPROVAL EVIDENCE"

  echo

  for c in "${COMMITS[@]}"; do

    echo

    echo "=================================================================="

    echo "COMMIT: $c"

    echo "=================================================================="

    git show --stat --name-only --oneline "$c" | head -100 || true

  done

  echo

  echo "=================================================================="

  echo "FILES CONTAINING APPROVAL / PREVIEW LANGUAGE"

  echo "=================================================================="

  rg -l -i "preview approval|execution approval|approval gate|planning artifact|reviewable planning|governance validation lifecycle|planning versus execution authority" . || true

} | tee "$REPORT"

echo

echo "Report written to: $REPORT"

git add inspect-governance-approval-evidence.sh "$REPORT"

git commit -m "Inspect governance approval evidence" || true

git push

