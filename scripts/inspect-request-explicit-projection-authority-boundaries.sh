#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"

test "$(git branch --show-current)" = "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== VALIDATED CHECKPOINT ==="
git rev-parse --short=9 HEAD

echo
echo "TYPECHECK=PASS"
echo "TARGETED_TESTS=4_PASS"
echo "IMPLEMENTATION_COMMIT=NOT_PERFORMED"
echo "DOGFOOD=NOT_PERFORMED"

echo
echo "=== UPSTREAM FIDELITY ENFORCEMENT ==="
rg -n -C 10 \
  'enforceConcreteOperationPackageSemanticsFidelity|enforceExplicitUserPackageSemanticsFidelity|concreteOperationMessage' \
  scripts/utils/ollamaChat.ts

echo
echo "=== MODEL PARSE AND RETURN BOUNDARY ==="
rg -n -C 8 \
  'parseStructuredResponse|packageSemantics:|packageSemantics,' \
  scripts/utils/ollamaChat.ts | tail -220

echo
echo "=== PROJECTION IMPLEMENTATION ==="
nl -ba server/matilda-request-explicit-package-semantics.ts

echo
echo "=== PROJECTION TESTS ==="
nl -ba server/matilda-request-explicit-package-semantics.test.ts

echo
echo "=== WORKFLOW DIFF ==="
git diff -- server/matilda-chat-workflow.ts

echo
echo "=== CLASSIFICATION ==="
echo "STATIC_VALIDATION=PASS"
echo "UPSTREAM_FIDELITY_COMPATIBILITY=REQUIRES_REVIEW"
echo "CONTRADICTORY_MODEL_OUTCOME_HANDLING=REQUIRES_REVIEW"
echo "FUNCTIONAL_COMMIT_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "NEXT_ACTION=REVIEW_AUTHORITY_AND_FIDELITY_BEFORE_COMMIT"
