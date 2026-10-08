#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="145259c3a"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== VERIFIED STABLE BASELINE ==="
git rev-parse --short=9 HEAD

test -z "$(git status --short -- \
  server/matilda-chat-workflow.ts \
  server/matilda-request-explicit-package-semantics.ts \
  server/matilda-request-explicit-package-semantics.test.ts)"

echo "ROLLBACK=COMPLETE"
echo "FUNCTIONAL_SOURCE=UNCHANGED"

echo
echo "=== UPSTREAM RECONCILIATION BOUNDARY ==="
sed -n '1455,1490p' scripts/utils/ollamaChat.ts

echo
echo "=== EXPLICIT USER FIDELITY BOUNDARY ==="
sed -n '495,525p' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT REQUEST FIDELITY BOUNDARY ==="
sed -n '965,1035p' scripts/utils/ollamaChat.ts

echo
echo "=== DESIGN DETERMINATION ==="
echo "VALIDATION_SEAM=OLLAMA_CHAT_PRE_RETURN"
echo "DOWNSTREAM_PROJECTION=REJECTED"
echo "MODEL_AUTHORED_CONTRADICTIONS=MUST_NOT_BE_SILENTLY_OVERWRITTEN"
echo "EXPLICIT_USER_FIELDS=MUST_RETAIN_EXACT_FIDELITY"
echo "OPERATION_AND_SUBJECT=MUST_RETAIN_FIDELITY"
echo "UNSUPPORTED_INFERENCE=PROHIBITED"
echo "AUTHORITY_CREATION=PROHIBITED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DOGFOOD_AUTHORIZED=NO"
echo "NEXT_ACTION=EXPLICIT_DESIGN_AUTHORIZATION"
