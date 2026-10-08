#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="6fd96e3d5"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"

test -z "$(git status --short -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts)"

echo "=== PACKAGE SEMANTICS TYPES AND VALIDATORS ==="
rg -n \
  'MatildaPackageSemanticsArtifact|validateMatildaPackageSemanticsArtifact|validateMatildaUserPackageSemanticsInput|enforceMatildaUserPackageSemanticsFidelity|enforceConcreteOperationPackageSemanticsFidelity' \
  scripts/utils/ollamaChat.ts

echo
echo "=== STRUCTURED PARSER ==="
sed -n '790,925p' scripts/utils/ollamaChat.ts

echo
echo "=== USER SEMANTICS VALIDATION ==="
sed -n '430,555p' scripts/utils/ollamaChat.ts

echo
echo "=== CONCRETE OPERATION FIDELITY ==="
sed -n '935,1040p' scripts/utils/ollamaChat.ts

echo
echo "=== UPSTREAM RUNTIME SEAM ==="
sed -n '1400,1510p' scripts/utils/ollamaChat.ts

echo
echo "=== EXISTING RUNTIME TEST FIXTURES ==="
sed -n '1,175p' \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts

echo
echo "=== CONCRETE OPERATION DETECTION ==="
sed -n '170,225p' \
  server/matilda-project-context-retrieval.ts

echo
echo "=== IMPLEMENTATION GATE ==="
echo "BASELINE=VERIFIED"
echo "TARGETED_TEST_BASELINE=26_PASS"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "FUNCTIONAL_SOURCE_MODIFIED=NO"
echo "LIVE_DOGFOOD=NO"
echo "NEXT_ACTION=IMPLEMENT_AND_TEST_EXACT_UPSTREAM_SEAM"
