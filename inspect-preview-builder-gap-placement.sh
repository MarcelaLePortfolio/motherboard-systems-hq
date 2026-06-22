
#!/usr/bin/env bash

set -euo pipefail

REPORT="preview-builder-gap-placement-inspection.txt"

{

  echo "PREVIEW BUILDER GAP PLACEMENT INSPECTION"

  echo

  echo "--- current head ---"

  git log --oneline -6

  echo

  echo "--- risk / rollback / visual preview references ---"

  rg -n -i "risk|rollback|revert|visual preview|preview builder|expected_output|planned_steps|planned_patches|reconciliation" \

    server/execution/cade-engineer-adapter.mjs \

    server/execution/build-execution-envelope-draft.mjs \

    server/contracts/execution-envelope.v1.mjs \

    server/execution/build-reconciliation-summary.mjs \

    public/js/planning-preview-card.js \

    docs/contracts \

    --glob '!bundle.js' --glob '!bundle.js.map' || true

  echo

  echo "--- execution envelope draft relevant excerpts ---"

  rg -n -i "objective|summary|steps|patches|expected_output|risk|rollback|scope|constraints" server/execution/build-execution-envelope-draft.mjs server/contracts/execution-envelope.v1.mjs || true

  echo

  echo "--- reconciliation summary shape ---"

  sed -n '1,220p' server/execution/build-reconciliation-summary.mjs

} | tee "$REPORT"

cat > preview-builder-gap-placement-finding.txt << 'EOF'

PREVIEW BUILDER GAP PLACEMENT FINDING

Finding Status: INSPECTION ONLY

Current known source material:

- Cade planning adapter already produces summary, planned_steps, planned_patches, expected_output, and reconciliation output.

- These fields are likely sufficient for the first preview-builder draft.

Current unresolved gaps:

- risk

- rollback

- visual preview

Inspection purpose:

Determine whether risk, rollback, and visual preview source material already exists in the envelope, reconciliation layer, planning adapter, or dashboard preview layer.

Scope boundaries:

- No UI implementation.

- No approval implementation.

- No preview-confirmation implementation.

- No mutation.

- No shell execution.

- No autonomous execution.

