#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="cfefbb3ed"
VALIDATOR="scripts/validate-package-semantics-grounding-under-proven-runner.sh"
TARGET="scripts/utils/ollamaChat.ts"
NEW_TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== INSPECT VALIDATOR EARLY EXIT ==="
echo "HEAD=$EXPECTED_HEAD"
echo "VALIDATION_SUCCESS_ESTABLISHED=NO"
echo "IMPLEMENTATION_FAILURE_ESTABLISHED=NO"
echo "ATTEMPT_3_STARTED=NO"
echo "DOGFOOD_RETRY=NO"

echo
echo "=== VALIDATOR CONTENT ==="
nl -ba "$VALIDATOR" | sed -n '1,180p'

echo
echo "=== VALIDATOR SYNTAX ==="
bash -n "$VALIDATOR"
echo "VALIDATOR_BASH_SYNTAX=PASS"

echo
echo "=== TRACE VALIDATOR UNTIL FIRST EXIT ==="
set +e
bash -x "$VALIDATOR" \
  > /tmp/package-semantics-grounding-validator.stdout \
  2> /tmp/package-semantics-grounding-validator.stderr
VALIDATOR_EXIT=$?
set -e

echo "VALIDATOR_EXIT=$VALIDATOR_EXIT"

echo
echo "--- STDOUT ---"
cat /tmp/package-semantics-grounding-validator.stdout

echo
echo "--- STDERR TRACE ---"
cat /tmp/package-semantics-grounding-validator.stderr

echo
echo "=== AUTHORIZED WORKTREE STATE ==="
git status --short -- "$TARGET" "$NEW_TEST"

grep -q \
  'expectedOutcome must preserve the operation and direction established by the current user request' \
  "$TARGET"
echo "DIRECTION_GROUNDING_PRESENT=YES"

grep -q \
  'Treat preservation requirements as constraints on the requested operation' \
  "$TARGET"
echo "PRESERVATION_CONSTRAINT_GROUNDING_PRESENT=YES"

test -f "$NEW_TEST"
echo "GROUNDING_TEST_FILE_PRESENT=YES"

echo
echo "=== CLASSIFICATION ==="
echo "VALIDATOR_EXECUTED_WITH_TRACE=YES"
echo "VALIDATOR_EXIT=$VALIDATOR_EXIT"
echo "ATTEMPT_2_VALIDATION_SUCCESS_ESTABLISHED=NO"
echo "ATTEMPT_2_IMPLEMENTATION_FAILURE_ESTABLISHED=NO"
echo "ATTEMPT_3_REQUIRED=NO"
echo "NEXT_ACTION=CLASSIFY_FIRST_FAILING_VALIDATOR_COMMAND_FROM_TRACE"
echo "LIVE_DOGFOOD_PERFORMED=NO"

echo
echo "=== SAFETY ==="
echo "NO_NEW_FUNCTIONAL_MUTATION_INTENDED=YES"
echo "NO_VALIDATOR_MUTATION=YES"
echo "NO_DATABASE_MUTATION=YES"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
