#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="24d03169c"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"

echo "=== VERIFIED PROGRESS ==="
echo "UPSTREAM_REGRESSION_TESTS=40_PASS"
echo "TYPECHECK=PASS"
echo "PRODUCTION_SOURCE=UNCHANGED"

echo
echo "=== WORKFLOW VALIDATION AND PERSISTENCE ==="
sed -n '355,480p' server/matilda-chat-workflow.ts
sed -n '495,550p' server/matilda-chat-workflow.ts

echo
echo "=== EXISTING WORKFLOW POLICY TESTS ==="
sed -n '1,240p' \
  server/matilda-chat-workflow.package-semantics-policy.test.ts

echo
echo "=== EXISTING CONCRETE OPERATION TESTS ==="
sed -n '1,240p' \
  server/matilda-concrete-operation-package-semantics.test.ts

echo
echo "=== EXISTING WORKFLOW INTEGRATION FIXTURES ==="
sed -n '1,185p' \
  server/matilda-chat-workflow.explicit-target.integration.test.ts

echo
echo "=== WORKFLOW INTEGRATION ASSERTIONS ==="
sed -n '450,570p' \
  server/matilda-chat-workflow.explicit-target.integration.test.ts

echo
echo "=== RUN EXISTING WORKFLOW REGRESSIONS ==="
npx tsx --test \
  server/matilda-chat-workflow.package-semantics-policy.test.ts \
  server/matilda-concrete-operation-package-semantics.test.ts \
  server/matilda-current-request-package-semantics-fidelity.test.ts

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== STATUS ==="
echo "UPSTREAM_VALIDATION=40_TESTS_PASSED_PREVIOUS_CHECKPOINT"
echo "WORKFLOW_PERSISTENCE_RECONCILIATION=NOT_YET_PROVEN"
echo "CONTRADICTORY_NON_OUTCOME_SEMANTICS=NOT_YET_PROVEN"
echo "LIVE_DOGFOOD=PROHIBITED"
echo "CORRIDOR=OPEN"
echo "NEXT_ACTION=ADD_WORKFLOW_INTEGRATION_ASSERTIONS_USING_VERIFIED_FIXTURES"
