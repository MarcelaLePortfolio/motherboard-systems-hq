
#!/usr/bin/env bash

set -euo pipefail

echo "Phase 738 governance schema verification"

echo "Status: READ-ONLY / NON-EXECUTING"

required_files=(

  "PHASE_738_GOVERNED_EXECUTION_LIFECYCLE.md"

  "STRUCTURED_DIFF_SCHEMA_DRAFT.md"

  "MATILDA_APPROVAL_ARTIFACT_SCHEMA_DRAFT.md"

  "EXECUTION_AUDIT_ARTIFACT_SCHEMA_DRAFT.md"

  "RECONCILIATION_REPORT_SCHEMA_DRAFT.md"

  "ROLLBACK_PROOF_SCHEMA_DRAFT.md"

  "DISASTER_RECOVERY/phase738-governance-schema-manifest.md"

)

for file in "${required_files[@]}"; do

  if [[ ! -f "$file" ]]; then

    echo "FAIL: missing $file"

    exit 1

  fi

  echo "PASS: found $file"

done

echo "Current commit:"

git rev-parse --short HEAD

echo "Working tree status:"

git status --short

if [[ -n "$(git status --short)" ]]; then

  echo "FAIL: working tree is not clean"

  exit 1

fi

echo "PASS: Phase 738 governance schema artifacts verified"

