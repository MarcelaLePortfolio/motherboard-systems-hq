#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="7c946d749"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== ATTEMPT 1 RESULT ==="
echo "FUNCTIONAL_MUTATION=NONE"
echo "FAILURE=EXPECTED_PROMPT_ANCHOR_NOT_FOUND"
echo "FAIL_CLOSED_BEHAVIOR=CORRECT"
echo "IMPLEMENTATION_HYPOTHESIS_FAILURE_COUNT=1_OF_3"
echo "AUTHORIZED_IMPLEMENTATION_REMAINS_PENDING=YES"

echo
echo "=== EXACT PACKAGE SEMANTICS PROMPT OCCURRENCES ==="
grep -n -B12 -A35 -Ei \
  'packageSemantics|Package Semantics|expectedOutcome|expected outcome' \
  "$TARGET" | head -700 || true

echo
echo "=== REQUIRE PACKAGE SEMANTICS PROMPT REGION ==="
grep -n -B20 -A80 \
  'requirePackageSemantics' \
  "$TARGET" | head -600 || true

echo
echo "=== PROMPT ARRAY / MESSAGE CONSTRUCTION REGION ==="
grep -n -B15 -A60 -Ei \
  'messages|system.*content|prompt|instructions' \
  "$TARGET" | head -800 || true

echo
echo "=== DECISION BOUNDARY ==="
echo "PURPOSE=LOCATE_EXACT_EXISTING_PROMPT_ANCHOR_BEFORE_CONTROLLED_ATTEMPT_2"
echo "DO_NOT_GUESS_ANCHOR=YES"
echo "DO_NOT_MUTATE_TARGET=YES"
echo "DOGFOOD_RETRY=NO"

echo
echo "=== SAFETY ==="
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
echo "TARGET_CODE_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
