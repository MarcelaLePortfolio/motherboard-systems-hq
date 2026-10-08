#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="20cbfffb7"

echo "=== VERIFY REPOSITORY BASELINE ==="

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"

test -z "$(git status --short -- \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.bounded-reconciliation.test.ts)"

echo "BASELINE=VERIFIED"
echo "FUNCTIONAL_SOURCE=UNCHANGED"

echo
echo "=== EXISTING RECONCILIATION TESTS ==="

rg -n '^test\(' \
  scripts/utils/ollamaChat.bounded-reconciliation.test.ts

echo
echo "=== REVIEW RUNTIME TEST CONTRACT ==="

sed -n '1,180p' \
  scripts/utils/ollamaChat.bounded-reconciliation.test.ts

echo
echo "=== REVIEW VALIDATION BOUNDARY ==="

sed -n '1455,1530p' scripts/utils/ollamaChat.ts

echo
echo "=== RUN TARGETED REGRESSION BASELINE ==="

npx tsx --test \
  scripts/utils/ollamaChat.bounded-reconciliation.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts \
  scripts/utils/ollamaChat.current-request-package-semantics-fidelity.test.ts

echo
echo "=== TYPECHECK ==="

npx tsc --noEmit

echo
echo "=== CLASSIFICATION ==="

echo "IMPLEMENTATION_BASELINE=STABLE"
echo "REGRESSION_EXPANSION=READY"
echo "PRODUCTION_SOURCE_CHANGES=NONE"
echo "LIVE_DOGFOOD=NONE"
echo "CORRIDOR=OPEN"
echo "NEXT_ACTION=ADD_MISSING_TARGETED_REGRESSION_TESTS"
