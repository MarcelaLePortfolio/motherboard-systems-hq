
#!/usr/bin/env bash

set -euo pipefail

REPORT="preview-builder-source-material-inspection.txt"

{

  echo "PREVIEW BUILDER SOURCE MATERIAL INSPECTION"

  echo

  echo "--- current head ---"

  git log --oneline -8

  echo

  echo "--- source files likely feeding preview builder ---"

  rg -n -i "objective|intent|interpreted|proposed|planned|risk|rollback|reconciliation|visual preview|preview-confirmation|planned_patches|affected|files|summary" \

    server/execution server/routes public/js docs/contracts \

    --glob '!bundle.js' --glob '!bundle.js.map' || true

  echo

  echo "--- governed planning route response construction ---"

  sed -n '260,330p' server/routes/governed-planning-route.mjs

  echo

  echo "--- Cade planning adapter shape ---"

  sed -n '1,260p' server/execution/cade-engineer-adapter.mjs

  echo

  echo "--- envelope draft shape excerpts ---"

  rg -n -i "objective|intent|scope|risk|rollback|mutation|planned|summary|constraints" server/execution/build-execution-envelope-draft.mjs server/contracts/execution-envelope.v1.mjs || true

} | tee "$REPORT"

cat > preview-builder-source-material-finding.txt << 'NOTE'

PREVIEW BUILDER SOURCE MATERIAL FINDING

Finding Status: INSPECTION ONLY

Question:

Does the current governed planning pipeline already contain the source material needed for a future Preview Builder?

Inspection target:

- interpreted request

- proposed work

- planned changes

- affected files/resources

- risks

- rollback path

- reconciliation summary

- visual preview candidates

Scope boundaries:

- No UI implementation.

- No approval implementation.

- No preview-confirmation implementation.

- No mutation.

- No shell execution.

- No autonomous execution.

NOTE

git add inspect-preview-builder-source-material.sh preview-builder-source-material-inspection.txt preview-builder-source-material-finding.txt

git commit -m "Inspect preview builder source material" || true

git push

