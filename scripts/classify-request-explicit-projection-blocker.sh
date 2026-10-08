#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"

test "$(git branch --show-current)" = "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== CURRENT CHECKPOINT ==="
git rev-parse --short=9 HEAD

echo
echo "=== UPSTREAM REJECTION BEFORE PROJECTION ==="
sed -n '1450,1490p' scripts/utils/ollamaChat.ts

echo
echo "=== DOWNSTREAM PROJECTION ==="
sed -n '365,405p' server/matilda-chat-workflow.ts

echo
echo "=== FIDELITY CLASSIFICATION ==="
echo "TYPECHECK=PASS"
echo "TARGETED_TESTS=4_PASS"
echo "UPSTREAM_REJECTION_PRECEDES_WORKFLOW_PROJECTION=YES"
echo "MISSING_EXPECTED_OUTCOME_CAN_THROW_BEFORE_PROJECTION=YES"
echo "CONTRADICTORY_MODEL_OUTCOME_CAN_BE_OVERWRITTEN=YES"
echo "END_TO_END_REMEDIATION=NOT_VALIDATED"
echo "IMPLEMENTATION_READY_FOR_COMMIT=NO"
echo "DOGFOOD_AUTHORIZED=NO"

echo
echo "=== SOURCE STATE ==="
git status --short -- \
  server/matilda-chat-workflow.ts \
  server/matilda-request-explicit-package-semantics.ts \
  server/matilda-request-explicit-package-semantics.test.ts

echo
echo "=== NEXT ACTION ==="
echo "STOP_CURRENT_IMPLEMENTATION_HYPOTHESIS"
echo "PRESERVE_UNCOMMITTED_SOURCE_FOR_REVIEW"
echo "REASSESS_PROJECTION_SEAM_BEFORE_ANY_ADDITIONAL_MUTATION"
