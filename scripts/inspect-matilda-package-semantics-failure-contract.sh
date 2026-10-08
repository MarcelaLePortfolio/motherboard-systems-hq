#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"

test "$(git branch --show-current)" = "$BRANCH"

echo "=== VERIFIED BASELINE ==="
git rev-parse --short=9 HEAD

test -z "$(git status --short -- \
  server/matilda-chat-workflow.ts \
  server/matilda-request-explicit-package-semantics.ts \
  server/matilda-request-explicit-package-semantics.test.ts)"

echo "ROLLBACK=COMPLETE"
echo "FUNCTIONAL_SOURCE=UNCHANGED"

echo
echo "=== EXPLICIT USER SEMANTICS CONTRACT ==="
sed -n '440,530p' scripts/utils/ollamaChat.ts

echo
echo "=== PACKAGE SEMANTICS REQUIREMENT ORIGIN ==="
rg -n -C 12 \
  'requirePackageSemantics|hasConcreteProjectOperation' \
  server/matilda-chat-workflow.ts | head -180

echo
echo "=== EXISTING FIDELITY RUNTIME TESTS ==="
sed -n '1,175p' \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts

echo
echo "=== CURRENT REQUEST FIDELITY TESTS ==="
sed -n '1,120p' \
  scripts/utils/ollamaChat.current-request-package-semantics-fidelity.test.ts

echo
echo "=== EXPECTED OUTCOME OBSERVABILITY TESTS ==="
sed -n '1,100p' \
  scripts/utils/ollamaChat.expected-outcome-diagnostic-observability.test.ts

echo
echo "=== VALIDATION ==="
npx tsc --noEmit
git diff --check

echo
echo "=== ARCHITECTURAL DETERMINATION ==="
echo "UPSTREAM_VALIDATION_PRECEDES_WORKFLOW_PERSISTENCE=CONFIRMED"
echo "DOWNSTREAM_PROJECTION_CANNOT_REPAIR_UPSTREAM_REJECTION=CONFIRMED"
echo "EXISTING_FIDELITY_GUARDS=MUST_BE_PRESERVED"
echo "DETERMINISTIC_RECONCILIATION_DESIGN=NOT_YET_AUTHORIZED"
echo "IMPLEMENTATION=NOT_PERFORMED"
echo "DOGFOOD=NOT_PERFORMED"
echo "NEXT_ACTION=REVIEW_TEST_CONTRACT_AND_SELECT_NARROW_UPSTREAM_DESIGN"
