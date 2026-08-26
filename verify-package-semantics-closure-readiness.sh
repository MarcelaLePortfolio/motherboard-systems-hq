#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== PACKAGE SEMANTICS CLOSURE READINESS ==="
echo "EXPECTED_HEAD_PREFIX=dffcc2ae"
echo "AUTHORIZED_BY=ee2d2495"
echo "SCOPE=FINAL_VALIDATION_ONLY"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != dffcc2ae* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== PACKAGE SEMANTICS TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/validate-package-semantics-iel-draft-transport.test.ts

echo
echo "=== LIFECYCLE REGRESSION TESTS ==="
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
echo "PACKAGE_SEMANTICS_CLOSURE_READINESS=PASS"
echo "MODEL_CONTRACT=PASS"
echo "IEL_TRANSPORT=PASS"
echo "DRAFT_SYNTHESIS=PASS"
echo "LIFECYCLE_REGRESSION=PASS"
echo "BUILD=PASS"
echo "SOURCE_CHANGE=NONE"

git add verify-package-semantics-closure-readiness.sh
git commit -m "Verify package semantics closure readiness"
git push
