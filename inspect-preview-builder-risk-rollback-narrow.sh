
#!/usr/bin/env bash

set -euo pipefail

REPORT="preview-builder-risk-rollback-narrow-inspection.txt"

{

  echo "PREVIEW BUILDER RISK / ROLLBACK NARROW INSPECTION"

  echo

  echo "--- current head ---"

  git log --oneline -6

  echo

  echo "--- scoped risk / rollback search only in active governed execution files ---"

  rg -n -i "risk|rollback|revert" server/execution/build-execution-envelope-draft.mjs server/contracts/execution-envelope.v1.mjs server/execution/build-reconciliation-summary.mjs || true

  echo

  echo "--- scoped preview-builder source fields already confirmed ---"

  rg -n "summary|planned_steps|planned_patches|expected_output|reconciliation" server/execution/cade-engineer-adapter.mjs || true

} | tee "$REPORT"

cat > preview-builder-risk-rollback-narrow-finding.txt << 'EOF'

PREVIEW BUILDER RISK / ROLLBACK NARROW FINDING

Finding Status: INSPECTION ONLY

Purpose:

Determine whether the active governed execution files already contain first-class risk, rollback, or revert fields for a future Preview Builder.

Known confirmed Preview Builder source fields already exist in the Cade planning adapter:

- summary

- planned_steps

- planned_patches

- expected_output

- reconciliation

This inspection intentionally excludes:

- node_modules

- backups

- restore-test archives

- historical checkpoint documents

Scope boundaries:

- No UI implementation.

- No approval implementation.

- No preview-confirmation implementation.

- No mutation.

- No shell execution.

- No autonomous execution.

