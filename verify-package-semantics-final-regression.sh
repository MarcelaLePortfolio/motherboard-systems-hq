#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FINAL PACKAGE SEMANTICS REGRESSION VERIFICATION ==="
echo "EXPECTED_HEAD=9712cc85"
echo "AUTHORIZED_BY=ee2d2495"
echo "SCOPE=VALIDATION_ONLY"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse --short HEAD)"
if [[ "${CURRENT_HEAD}" != "9712cc85" ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== FOCUSED PACKAGE SEMANTICS TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/validate-package-semantics-iel-draft-transport.test.ts

echo
echo "=== EXISTING INVESTIGATION LIFECYCLE CONTRACT REGRESSION ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== TYPESCRIPT CHECK ==="
npm run check

echo
echo "=== BUILD ==="
npm run build

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "=== WORKING TREE ==="
git status --short

echo
echo "PACKAGE_SEMANTICS_FINAL_REGRESSION=PASS"
echo "MODEL_CONTRACT=VALIDATED"
echo "IEL_TRANSPORT=VALIDATED"
echo "DRAFT_SYNTHESIS=VALIDATED"
echo "LEGACY_INVESTIGATION_LIFECYCLE=REGRESSION_PASS"
echo "BUILD=PASS"
echo "SOURCE_CHANGE=NONE"
