
#!/usr/bin/env bash

set -euo pipefail

echo "Phase 738 dry-run boundary verification"

echo "Status: READ-ONLY / NON-EXECUTING"

required_files=(

  "DRY_RUN_SIMULATION_BOUNDARY.md"

  "PHASE_738_GOVERNED_EXECUTION_LIFECYCLE.md"

  "STRUCTURED_DIFF_SCHEMA_DRAFT.md"

  "MATILDA_APPROVAL_ARTIFACT_SCHEMA_DRAFT.md"

  "EXECUTION_AUDIT_ARTIFACT_SCHEMA_DRAFT.md"

  "RECONCILIATION_REPORT_SCHEMA_DRAFT.md"

  "ROLLBACK_PROOF_SCHEMA_DRAFT.md"

)

for file in "${required_files[@]}"; do

  if [[ ! -f "$file" ]]; then

    echo "FAIL: missing $file"

    exit 1

  fi

  echo "PASS: found $file"

done

if ! grep -q "Dry-run simulation planning is governance-only infrastructure" DRY_RUN_SIMULATION_BOUNDARY.md; then

  echo "FAIL: dry-run locked boundary text missing"

  exit 1

fi

if ! grep -q "Simulation planning must not be reclassified" DRY_RUN_SIMULATION_BOUNDARY.md; then

  echo "FAIL: dry-run non-authority rule missing"

  exit 1

fi

echo "Current commit:"

git rev-parse --short HEAD

echo "Working tree status:"

git status --short

echo "PASS: Phase 738 dry-run boundary verified"

