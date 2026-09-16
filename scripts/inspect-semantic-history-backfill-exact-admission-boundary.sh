#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="eb60b2dca"
WORKFLOW="server/matilda-chat-workflow.ts"
COMPOSER="server/matilda-conversation-context-runtime.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== SEMANTIC HISTORY — EXACT BACKFILL ADMISSION BOUNDARY ====="
echo "MODE=AUTHORIZED_IMPLEMENTATION_PREPARATION"
echo "POLICY_BATCH_SIZE=20"
echo "POLICY_HARD_SCAN_CEILING=75"
echo "TARGET_SELECTED_HISTORY=20"

echo
echo "===== EXACT CONTEXT COMPOSITION IMPLEMENTATION ====="
sed -n '1,240p' "$COMPOSER"

echo
echo "===== EXACT WORKFLOW RETRIEVAL THROUGH OLLAMA BOUNDARY ====="
sed -n '165,285p' "$WORKFLOW"

echo
echo "===== WORKFLOW TEST FILES ====="
find server -maxdepth 1 -type f -name 'matilda-chat-workflow*.test.ts' -print | sort

echo
echo "===== WORKFLOW TEST HARNESS REFERENCES ====="
grep -Rni -A20 -B10 \
  -E 'runMatildaConversationWorkflow|listMatildaConversationTurns|ollamaChat|selectedHistory|conversationContext' \
  server/matilda-chat-workflow*.test.ts 2>/dev/null | head -n 400 || true

echo
echo "===== CLASSIFICATION TARGET ====="
echo "QUESTION_1=CAN_COMPOSER_BE_CALLED_AFTER_EACH_RETRIEVAL_BATCH_WITHOUT_SIDE_EFFECTS"
echo "QUESTION_2=CAN_SELECTED_HISTORY_LENGTH_BE_USED_AS_ELIGIBILITY_STOP_CONDITION"
echo "QUESTION_3=HOW_TO_ACCUMULATE_PAGES_WHILE_PRESERVING_GLOBAL_CHRONOLOGY"
echo "QUESTION_4=HOW_TO_TRIM_FINAL_RESULT_TO_NEWEST_20_ELIGIBLE_TURNS"
echo "QUESTION_5=WHICH_EXISTING_WORKFLOW_TEST_CAN_VERIFY_SINGLE_OLLAMA_INVOCATION"
echo "QUESTION_6=CAN_EXACT_ID_IEL_LOOKUP_REMAIN_AFTER_RETRIEVAL_ACCUMULATION"

echo
echo "===== IMMUTABLE IMPLEMENTATION CONTRACT ====="
echo "BATCH_SIZE=20"
echo "HARD_SCAN_CEILING=75"
echo "TARGET_SELECTED_HISTORY=20"
echo "AUTHORITY_ADMISSION=PRESERVE"
echo "CONTAMINATION_ADMISSION=PRESERVE"
echo "SEMANTIC_RANKING=NONE"
echo "CHRONOLOGY=PRESERVE"
echo "PRIOR_SUPPORT_PROVENANCE=NEWEST_SELECTED_HISTORY_TURN"
echo "ONE_OLLAMA_INVOCATION=PRESERVE"
echo "READER_CURSOR=REUSE"
echo "READER_SOURCE_CHANGE=NO"
echo "OLLAMA_CHANGE=NO"
echo "PERSISTENCE_SCHEMA_CHANGE=NO"

echo
echo "===== NEXT ACTION ====="
echo "NEXT_ACTION=CLASSIFY_EXACT_LOOP_AND_REGRESSION_TEST_INSERTION_POINT_FROM_VERIFIED_SOURCE"
echo "SOURCE_CHANGE=NONE"
echo "STAGING=NONE"
echo "COMMIT=NONE"
echo "PUSH=NONE"

echo
echo "===== WORKTREE ====="
git status --short
