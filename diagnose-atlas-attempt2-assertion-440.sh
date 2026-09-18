#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== ATTEMPT 2 FAILURE BASELINE ===\n'
echo "ATTEMPT_2_RESULT=FAILED"
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
echo "TYPECHECK=PASS"
echo "ATLAS_REGRESSIONS=PASS"
echo "PRODUCT_BOUNDARIES=PASS"
echo "OBSERVED_FAILURE=ASSERTION_0_NE_1_AT_LINE_440"
echo "ATTEMPT_3_AUTHORIZED=NO"

printf '\n=== EXACT FAILING ASSERTION ===\n'
nl -ba "$TEST" | sed -n '425,450p'

printf '\n=== FULL LOCAL EXECUTION SEAM ===\n'
nl -ba "$TEST" | sed -n '390,470p'

printf '\n=== IDENTIFY ASSERTED VALUE OR COLLECTION ===\n'
sed -n '425,450p' "$TEST" |
  grep -n -E \
    'assert|length|ollama|entry|turn|conversation|result|ledger' \
    || true

printf '\n=== TRACE RELEVANT SYMBOLS THROUGH TEST ===\n'
grep -n -E \
  'ollamaInvocationCount|ollamaBeforeBackfill|beforeTargetEntries|insertLedger|runMatildaConversationWorkflow|backfill|length' \
  "$TEST" || true

printf '\n=== TRACE WORKFLOW GATES ===\n'
grep -n -A10 -B10 -E \
  'runMatildaConversationWorkflow|Ollama|ollama|interpretation|evidence|return|conversationId' \
  server/matilda-chat-workflow.ts |
  sed -n '1,360p' || true

printf '\n=== CLASSIFICATION QUESTIONS ===\n'
echo "Q1=What exact value is asserted to equal 1 at line 440?"
echo "Q2=Is that assertion part of the pre-existing integration test or the new Atlas lifecycle assertions?"
echo "Q3=Did Attempt 2 expose an existing fixture expectation after repairing the missing IEL table?"
echo "Q4=Can any Attempt 3 be confined to the authorized test fixture without weakening an existing behavioral assertion?"

printf '\n=== VERIFY AUTHORIZED TEST PRESERVED ===\n'
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

printf '\n=== STOPPING POINT ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
echo "ATTEMPT_3_AUTHORIZED=NO"
echo "ATTEMPT_3_EXECUTED=NO"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=CLASSIFY_EXACT_LINE_440_FAILURE_BEFORE_ATTEMPT_3"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
echo "NO ATTEMPT 3 / NO TEST COMMIT / NO TEST PUSH"
