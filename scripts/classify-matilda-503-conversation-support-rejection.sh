#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=84c35b45' \
  'MODE=COLLABORATION_DIAGNOSTIC' \
  'PRODUCTION_CHANGE=NONE' \
  'ROOT_EXCEPTION=OLLAMA_RETURNED_CONVERSATION_SUPPORT_REFERENCE_NOT_SUPPLIED' \
  'ISSUE_RESOLVED=NO' \
  'FIX_AUTHORIZED=NO' \
  'TARGET=CLASSIFY_EXACT_REJECTION_AGAINST_EXISTING_PROVENANCE_CONTRACT'

printf '\n=== EXACT FAIL-CLOSED SITE ===\n'
sed -n '1060,1135p' scripts/utils/ollamaChat.ts

printf '\n=== CONVERSATION SUPPORT VALIDATION HELPERS ===\n'
grep -n -A35 -B20 -E \
  'conversation support reference|conversationSupport|supportSourceReferences|supplied.*conversation|conversation.*supplied' \
  scripts/utils/ollamaChat.ts | head -320

printf '\n=== PROMPT CONVERSATION SUPPORT CONTRACT ===\n'
grep -n -A45 -B25 -E \
  'conversation support|supportSourceReferences|conversation history|Conversation context|conversationContext' \
  scripts/utils/ollamaChat.ts | head -360

printf '\n=== WORKFLOW INPUT TO OLLAMA ===\n'
sed -n '175,235p' server/matilda-chat-workflow.ts

printf '\n=== CURRENT CONVERSATION STATE ===\n'
sqlite3 -header -column db/main.db "
SELECT
  conversation_id,
  project_id,
  status,
  title,
  created_at,
  updated_at,
  last_active_at
FROM matilda_conversations
WHERE conversation_id = 'matilda-conversation-hq-1787159584712-q6x7o3';

SELECT
  turn_id,
  conversation_id,
  user_message,
  assistant_reply,
  created_at
FROM matilda_conversation_turns
WHERE conversation_id = 'matilda-conversation-hq-1787159584712-q6x7o3'
ORDER BY rowid ASC;
" || true

printf '\n=== RELEVANT TEST COVERAGE ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
  -E 'conversation support reference that was not supplied|conversation support reference|conversation.*support.*supplied' \
  scripts server routes db tests 2>/dev/null | head -260

printf '\n=== HISTORICAL RELATED RUNNERS ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
  -E 'support provenance|conversation support|production stability|unseeded' \
  scripts 2>/dev/null | head -260

printf '\n=== CLASSIFICATION BOUNDARY ===\n'
printf '%s\n' \
  'LIVE_503_ROOT_CAUSE_LOCALIZED=YES' \
  'FAIL_CLOSED_VALIDATOR_TRIGGERED=YES' \
  'VALIDATOR_MALFUNCTION_ESTABLISHED=NO' \
  'MODEL_OUTPUT_CONTRACT_VIOLATION_ESTABLISHED=YES' \
  'KNOWN_HISTORICAL_PROJECT_SUPPORT_FAILURE_CLASS_DIFFERENT=YES' \
  'CURRENT_FAILURE_CLASS=INVALID_MODEL_AUTHORED_CONVERSATION_SUPPORT_PROVENANCE' \
  'SAFE_FIX_NOT_YET_ESTABLISHED=YES' \
  'NEXT_ACTION=DETERMINE_WHETHER_PROMPT_SUPPLY_SET_OR_MODEL_REFERENCE_FORMAT_IS_MISALIGNED_BEFORE_AUTHORIZING_FIX'

printf '\n=== WORKTREE ===\n'
git status --short
