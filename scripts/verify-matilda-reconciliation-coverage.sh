#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="e2dd8a242"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test -z "$(git status --short -- \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.bounded-reconciliation.test.ts)"

echo "=== IMPLEMENTATION CHECKPOINT ==="
echo "HEAD=$(git rev-parse --short=9 HEAD)"
echo "IMPLEMENTATION=COMMITTED_AND_PUSHED"

echo
echo "=== VERIFY IMPLEMENTED RECONCILIATION ==="
sed -n '1455,1525p' scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY REGRESSION COVERAGE ==="
rg -n '^test\(' \
  scripts/utils/ollamaChat.bounded-reconciliation.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts

echo
echo "=== VERIFY DESIGN REQUIREMENTS ==="
sed -n '1,120p' \
  docs/governance/MATILDA_BOUNDED_UPSTREAM_PACKAGE_SEMANTICS_DESIGN.md

echo
echo "=== TARGETED TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.bounded-reconciliation.test.ts \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts \
  scripts/utils/ollamaChat.current-request-package-semantics-fidelity.test.ts

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== CLASSIFICATION ==="
echo "IMPLEMENTATION=COMMITTED"
echo "TARGETED_TESTS=PASS"
echo "TYPECHECK=PASS"
echo "DESIGN_TEST_MATRIX=REQUIRES_COMPLETENESS_REVIEW"
echo "LIVE_DOGFOOD=NOT_AUTHORIZED"
echo "CORRIDOR=COVERAGE_VALIDATION_ACTIVE"
echo "NEXT_ACTION=ASSESS_MISSING_REGRESSION_CASES"
