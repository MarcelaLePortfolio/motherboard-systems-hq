#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="7019b1846767da562a66c76be4124b8f0b3949ff"
WORKFLOW="server/matilda-chat-workflow.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$BASELINE"
test "$(git rev-parse "origin/$BRANCH")" = "$BASELINE"

echo "===== SEMANTIC HISTORY — AUTHORIZED BACKFILL IMPLEMENTATION BOUNDARY ====="
echo "POLICY_BATCH_SIZE=20"
echo "POLICY_HARD_SCAN_CEILING=75"
echo "TARGET_SELECTED_HISTORY=20"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "PURPOSE=VERIFY_EXACT_WORKFLOW_BOUNDARY_BEFORE_SOURCE_EDIT"

echo
echo "===== READER / COMPOSITION REFERENCES ====="
grep -n -A45 -B25 \
  -E 'listMatildaConversationTurns|composeMatildaConversationContext|selectedHistory|priorSupport|supportProvenance|ollama' \
  "$WORKFLOW" || true

echo
echo "===== READER SIGNATURE ====="
grep -n -A90 -B10 \
  'export function listMatildaConversationTurns' \
  db/matilda-conversation-runtime.ts

echo
echo "===== RELEVANT TEST SURFACES ====="
grep -Rni \
  -E 'composeMatildaConversationContext|selectedHistory|listMatildaConversationTurns|single.*Ollama|Ollama.*invocation' \
  server/*.test.ts db/*.test.ts 2>/dev/null | head -n 250 || true

echo
echo "===== IMPLEMENTATION INVARIANTS ====="
echo "SEMANTIC_ADMISSION_CHANGE=NO"
echo "AUTHORITY_CHANGE=NO"
echo "CONTAMINATION_CHANGE=NO"
echo "SEMANTIC_RANKING=NO"
echo "SELECTED_HISTORY_TARGET=20"
echo "BACKFILL_BATCH=20"
echo "HARD_SCAN_CEILING=75"
echo "CHRONOLOGY=PRESERVE"
echo "PRIOR_SUPPORT_PROVENANCE=NEWEST_SELECTED_HISTORY_TURN"
echo "ONE_OLLAMA_INVOCATION=PRESERVE"
echo "READER_CURSOR=REUSE_EXISTING"
echo "NEXT_ACTION=IMPLEMENT_ONLY_IF_EXACT_WORKFLOW_AND_TEST_INSERTION_BOUNDARIES_ARE_ESTABLISHED"

echo
echo "===== WORKTREE ====="
git status --short
