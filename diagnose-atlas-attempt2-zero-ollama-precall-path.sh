#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"
WORKFLOW="server/matilda-chat-workflow.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== PRESERVE FAILURE STATE ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
echo "ATTEMPT_1_FAILURE=MISSING_TEMPORARY_IEL_TABLE"
echo "ATTEMPT_2_FAILURE=PRE_EXISTING_BACKFILL_OLLAMA_ASSERTION_0_NE_1"
echo "ATTEMPT_2_IEL_SCHEMA_REPAIR=REMOVED_FIRST_BARRIER"
echo "ATTEMPT_3_AUTHORIZED=NO"
echo "ATTEMPT_3_EXECUTED=NO"

printf '\n=== VERIFY PRE-EXISTING ASSERTION FROM HEAD ===\n'
git show HEAD:"$TEST" |
  nl -ba |
  sed -n '400,455p'

printf '\n=== CURRENT ASSERTION REGION ===\n'
nl -ba "$TEST" |
  sed -n '400,455p'

printf '\n=== LOCATE OLLAMA INVOCATION COUNTER ===\n'
grep -n -A30 -B20 \
  'ollamaInvocationCount += 1' \
  "$TEST" || true

printf '\n=== LOCATE WORKFLOW OLLAMA CALL ===\n'
grep -n -A45 -B45 \
  'await ollamaChat' \
  "$WORKFLOW" || true

printf '\n=== LOCATE WORKFLOW PRE-OLLAMA OPERATIONS ===\n'
sed -n '133,378p' "$WORKFLOW" |
  nl -ba |
  sed -n '1,300p'

printf '\n=== LOCATE CATCH / FALLBACK PATHS ===\n'
grep -n -A100 -B20 -E \
  'catch[[:space:]]*\(|catch[[:space:]]*\{|MatildaConversationWorkflowUnavailableError|return result|return \{' \
  "$WORKFLOW" |
  tail -320 || true

printf '\n=== LOCATE TEST OLLAMA STUB MATCHING ===\n'
nl -ba "$TEST" |
  sed -n '90,180p'

printf '\n=== CLASSIFY ZERO-INVOCATION POSSIBILITY ===\n'
cat <<'CLASSIFICATION'
KNOWN_1=workflow call returned far enough for line 440 assertion to execute
KNOWN_2=Ollama stub counter did not increment during that workflow call
KNOWN_3=the exactly-one-invocation assertion predates the Atlas lifecycle additions
KNOWN_4=the assertion must not be weakened merely to make Atlas validation pass
QUESTION_1=Does the workflow invoke a different Ollama endpoint or module instance than the fixture counter observes?
QUESTION_2=Does a pre-Ollama operation fail and get converted into a returned workflow result?
QUESTION_3=Did temporary fixture schema initialization change module/database binding behavior?
QUESTION_4=Is another pre-existing fixture table/schema dependency required before ollamaChat?
CLASSIFICATION

printf '\n=== VERIFY AUTHORIZED TEST DIFF ONLY ===\n'
git diff --check -- "$TEST"
git status --short -- "$TEST"

printf '\n=== VERIFY PRODUCT BOUNDARIES ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== DIAGNOSTIC CLASSIFICATION ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
echo "ASSERTION_WEAKENING=PROHIBITED"
echo "ATTEMPT_3_AUTHORIZED=NO"
echo "ATTEMPT_3_EXECUTED=NO"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=IDENTIFY_EXACT_ZERO_OLLAMA_PRECALL_PATH"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"

printf '\n=== STOP ===\n'
echo "NO ATTEMPT 3 / NO TEST COMMIT / NO TEST PUSH"
