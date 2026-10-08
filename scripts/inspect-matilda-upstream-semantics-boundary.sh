#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"

test "$(git branch --show-current)" = "$BRANCH"

echo "=== RESTORED BASELINE ==="
git rev-parse --short=9 HEAD

test -z "$(git status --short -- \
  server/matilda-chat-workflow.ts \
  server/matilda-request-explicit-package-semantics.ts \
  server/matilda-request-explicit-package-semantics.test.ts)"

echo "ROLLBACK=VERIFIED"
echo "FUNCTIONAL_SOURCE_CHANGES=NONE"

echo
echo "=== PACKAGE SEMANTICS VALIDATION ORDER ==="
sed -n '1435,1500p' scripts/utils/ollamaChat.ts

echo
echo "=== CONCRETE OPERATION FIDELITY CONTRACT ==="
sed -n '940,1040p' scripts/utils/ollamaChat.ts

echo
echo "=== EXPLICIT USER SEMANTICS FIDELITY ==="
rg -n -C 8 \
  'function enforceMatildaUserPackageSemanticsFidelity|function validateMatildaUserPackageSemantics|validatedUserPackageSemantics' \
  scripts/utils/ollamaChat.ts

echo
echo "=== WORKFLOW AUTHORITY INPUTS ==="
sed -n '350,410p' server/matilda-chat-workflow.ts

echo
echo "=== EXISTING TEST COVERAGE ==="
rg -n \
  'expectedOutcome is required|current-request Package Semantics fidelity|non-null Package Semantics|concreteOperationMessage|observeValidatedPackageSemantics' \
  scripts server \
  --glob '*test*' \
  --glob '!dist/**' \
  | head -100 || true

echo
echo "=== CLASSIFICATION ==="
echo "RESTORED_BASELINE=STABLE"
echo "PREVIOUS_PROJECTION_SEAM=REJECTED"
echo "NEXT_STEP=REVIEW_EXISTING_UPSTREAM_CONTRACT"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DOGFOOD_AUTHORIZED=NO"
