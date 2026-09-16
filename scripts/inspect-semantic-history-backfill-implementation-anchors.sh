#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="813f199d1"
WORKFLOW="server/matilda-chat-workflow.ts"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== SEMANTIC HISTORY — IMPLEMENTATION ANCHOR INSPECTION ====="
echo "MODE=AUTHORIZED_IMPLEMENTATION_PREPARATION"
echo "BATCH_SIZE=20"
echo "HARD_SCAN_CEILING=75"
echo "TARGET_SELECTED_HISTORY=20"

echo
echo "===== WORKFLOW IMPORTS AND TYPES ====="
sed -n '1,180p' "$WORKFLOW"

echo
echo "===== EXACT RETRIEVAL / COMPOSITION REGION ====="
grep -n -A150 -B30 \
  'const conversationTurns' \
  "$WORKFLOW"

echo
echo "===== READER CURSOR SIGNATURE ====="
grep -n -A90 -B10 \
  'export function listMatildaConversationTurns' \
  db/matilda-conversation-runtime.ts

echo
echo "===== INTEGRATION TEST — OLLAMA STUB AND INVOCATION SURFACE ====="
grep -n -A120 -B30 \
  'createServer' \
  "$TEST"

echo
echo "===== INTEGRATION TEST — DATABASE AND CLEANUP TAIL ====="
tail -n 260 "$TEST"

echo
echo "===== IMPLEMENTATION ANCHORS TO CONFIRM ====="
echo "ANCHOR_1=CONVERSATION_TURNS_RETRIEVAL_BLOCK"
echo "ANCHOR_2=PRIOR_USER_MESSAGE_COMPUTATION"
echo "ANCHOR_3=PROJECT_CONTEXT_RETRIEVAL"
echo "ANCHOR_4=EXACT_ID_IEL_LOOKUP"
echo "ANCHOR_5=INTERPRETATION_LIFECYCLE_SELECTION"
echo "ANCHOR_6=CONVERSATION_CONTEXT_COMPOSITION"
echo "ANCHOR_7=OLLAMA_STUB_REQUEST_COUNTER_LOCATION"
echo "ANCHOR_8=TEST_DATABASE_DIRECT_INSERT_LOCATION"
echo "ANCHOR_9=TEST_CLEANUP_BOUNDARY"

echo
echo "===== AUTHORIZED POLICY ====="
echo "BACKFILL_BATCH_SIZE=20"
echo "HARD_SCAN_CEILING=75"
echo "TARGET_SELECTED_HISTORY=20"
echo "CURSOR=CREATED_AT_PLUS_TURN_ID"
echo "ACCUMULATION=OLDER_PAGE_PREPENDED"
echo "STOP_ON_SELECTED_HISTORY_GTE_TARGET=YES"
echo "STOP_ON_EXHAUSTION=YES"
echo "STOP_ON_SCAN_CEILING=YES"
echo "FINAL_HISTORY=NEWEST_20_ELIGIBLE"
echo "ONE_OLLAMA_INVOCATION=PRESERVE"

echo
echo "===== CHANGE BOUNDARY ====="
echo "WORKFLOW_SOURCE_CHANGE=AUTHORIZED"
echo "INTEGRATION_TEST_CHANGE=AUTHORIZED"
echo "READER_CHANGE=NO"
echo "COMPOSER_CHANGE=NO"
echo "SELECTION_CHANGE=NO"
echo "OLLAMA_CHANGE=NO"
echo "PERSISTENCE_SCHEMA_CHANGE=NO"

echo
echo "NEXT_ACTION=IMPLEMENT_ONLY_FROM_THE_VERIFIED_ANCHORS_PRINTED_ABOVE"
echo "SOURCE_CHANGE=NONE"
echo "STAGING=NONE"
echo "COMMIT=NONE"
echo "PUSH=NONE"

echo
echo "===== WORKTREE ====="
git status --short
