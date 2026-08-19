#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE' \
  'OLLAMA_SERVICE=HEALTHY' \
  'GEMMA3_4B=AVAILABLE' \
  'DIRECT_MODEL_GENERATION=PASS' \
  'UNSEEDED_RUNS=10' \
  'FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=0' \
  'FIXTURE_SEMANTIC_FAILURE_RUNS=10' \
  'UNIQUE_EXACT_OUTPUT_FINGERPRINTS=3' \
  'DETERMINATION=GENERIC_PRODUCTION_EQUIVALENT_RUNNER_DOES_NOT_REPRODUCE_UI_503' \
  'UI_REQUEST_SPECIFIC_DIAGNOSTIC_REQUIRED=YES' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'GENERATION_POLICY_CHANGE_AUTHORIZED=NO' \
  'NEXT_ACTION=TRACE_ACTUAL_API_CHAT_REQUEST_THROUGH_RUNMATILDACONVERSATIONWORKFLOW'

printf '\n=== LOCATE CHAT ROUTE AND WORKFLOW INPUT PATH ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'router\.post|/api/chat|runMatildaConversationWorkflow|runMatildaStub|MatildaConversationWorkflowUnavailableError' \
  routes server scripts 2>/dev/null | head -240

printf '\n=== WORKFLOW UNAVAILABLE THROW CONTEXT ===\n'
grep -n -A35 -B35 \
  'throw new MatildaConversationWorkflowUnavailableError' \
  server/matilda-chat-workflow.ts || true

printf '\n=== OLLAMA ADAPTER FAILURE / NULL RETURN CONTEXT ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
  -E 'return null|catch.*ollama|ollamaChat|runMatildaStub|validation.*fail|support.*reference' \
  server scripts/utils routes 2>/dev/null | head -280

printf '\n=== CURRENT ACTIVE CONVERSATION ===\n'
sqlite3 -header -column db/main.db "
SELECT *
FROM matilda_active_conversation_context
LIMIT 10;
" || true

printf '\n=== RECENT CONVERSATION TURNS ===\n'
sqlite3 -header -column db/main.db "
SELECT *
FROM matilda_conversation_turns
ORDER BY rowid DESC
LIMIT 8;
" || true

printf '\n=== CLASSIFICATION ===\n'
printf '%s\n' \
  'KNOWN_PROVENANCE_REJECTION_REPRODUCED=NO' \
  'GENERIC_RUNTIME_REJECTION_REPRODUCED=NO' \
  'UNSEEDED_SEMANTIC_INSTABILITY_REMAINS_OBSERVED=YES' \
  'UI_503_ROOT_CAUSE=NOT_YET_LOCALIZED' \
  'NEXT_EVIDENCE_REQUIRED=ACTUAL_UI_CHAT_WORKFLOW_FAILURE_PATH' \
  'FIX_AUTHORIZED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
