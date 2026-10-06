#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="dee65da92"
VALIDATOR="scripts/validate-package-semantics-grounding-under-proven-runner.sh"
TARGET="scripts/utils/ollamaChat.ts"
NEW_TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== EXECUTE PROVEN-RUNNER VALIDATION ==="
echo "HEAD=$EXPECTED_HEAD"
echo "ATTEMPT_2_STATUS=PENDING_VALIDATION"
echo "ATTEMPT_3_STARTED=NO"
echo "DOGFOOD_RETRY=NO"

test -x "$VALIDATOR"
test -f "$NEW_TEST"

grep -q \
  'expectedOutcome must preserve the operation and direction established by the current user request' \
  "$TARGET"

grep -q \
  'Treat preservation requirements as constraints on the requested operation' \
  "$TARGET"

echo "VALIDATOR_CONFIRMED=YES"
echo "AUTHORIZED_GROUNDING_CONFIRMED=YES"

echo
echo "=== RUN VALIDATOR ==="
"$VALIDATOR"

echo
echo "=== POST-VALIDATION RECONCILIATION ==="
echo "CURRENT_HEAD=$(git rev-parse --short=9 HEAD)"
git status --short -- "$TARGET" "$NEW_TEST"

if git diff --quiet -- "$TARGET" && \
   git ls-files --error-unmatch "$NEW_TEST" >/dev/null 2>&1; then
  echo "AUTHORIZED_FUNCTIONAL_CHANGE_COMMITTED=YES"
else
  echo "AUTHORIZED_FUNCTIONAL_CHANGE_COMMITTED=NO"
  echo "Validation script completed without committing the full authorized functional change."
  exit 1
fi

echo "ATTEMPT_2_VALIDATED=YES"
echo "ATTEMPT_3_REQUIRED=NO"
echo "LIVE_DOGFOOD_READY_FOR_NEXT_CONTROLLED_STEP=YES"
echo "LIVE_DOGFOOD_PERFORMED=NO"
