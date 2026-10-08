#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"

test "$(git branch --show-current)" = "$BRANCH"

echo "=== STABLE SOURCE BASELINE ==="
git rev-parse --short=9 HEAD

test -z "$(git status --short -- \
  server/matilda-chat-workflow.ts \
  server/matilda-request-explicit-package-semantics.ts \
  server/matilda-request-explicit-package-semantics.test.ts)"

echo "ROLLBACK=COMPLETE"
echo "FUNCTIONAL_SOURCE=UNCHANGED"

echo
echo "=== PACKAGE SEMANTICS VALIDATION SEQUENCE ==="
sed -n '1450,1490p' scripts/utils/ollamaChat.ts

echo
echo "=== STRUCTURED RESPONSE VALIDATION ==="
sed -n '875,940p' scripts/utils/ollamaChat.ts

echo
echo "=== CONCRETE OPERATION DETECTION ==="
rg -n -C 12 \
  'export function hasConcreteProjectOperation|function hasConcreteProjectOperation' \
  server/matilda-project-context-retrieval.ts

echo
echo "=== EXISTING SEMANTICS CONTRACT TESTS ==="
rg -n \
  'requirePackageSemantics|concreteOperationMessage|expectedOutcome|packageSemantics' \
  scripts/utils/ollamaChat.*test.ts \
  server/matilda-current-request-package-semantics-fidelity.test.ts \
  | head -130

echo
echo "=== ARCHITECTURAL REVIEW RESULT ==="
echo "SOURCE_BASELINE=STABLE"
echo "FAILURE_LOCATION=OLLAMA_CHAT_PRE_RETURN_VALIDATION"
echo "DOWNSTREAM_PROJECTION=UNSUITABLE"
echo "EXPLICIT_USER_SEMANTICS_FIDELITY=MUST_REMAIN_FAIL_CLOSED"
echo "CURRENT_REQUEST_OPERATION_AND_SUBJECT_FIDELITY=MUST_REMAIN_FAIL_CLOSED"
echo "UNSUPPORTED_SEMANTICS_INVENTION=PROHIBITED"
echo "AUTHORITY_CREATION=PROHIBITED"
echo "PROPOSED_DIRECTION=BOUNDED_PRE_VALIDATION_RECONCILIATION"
echo "DESIGN_APPROVAL=REQUIRED_BEFORE_IMPLEMENTATION"
echo "FUNCTIONAL_SOURCE_COMMIT=NONE"
echo "DOGFOOD=NONE"
