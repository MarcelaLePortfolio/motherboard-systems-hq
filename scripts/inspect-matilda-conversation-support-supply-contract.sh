#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=922d432e' \
  'MODE=COLLABORATION_DIAGNOSTIC' \
  'PRODUCTION_CHANGE=NONE' \
  'ISSUE_RESOLVED=NO' \
  'ROOT_CAUSE=INVALID_MODEL_AUTHORED_CONVERSATION_SUPPORT_PROVENANCE' \
  'TARGET=DETERMINE_WHETHER_EMPTY_CONVERSATION_SUPPLY_SET_AND_PROMPT_CONTRACT_ARE_MISALIGNED'

printf '\n=== SUPPLIED CONVERSATION SOURCE ID CONSTRUCTION ===\n'
grep -n -A55 -B35 \
  'suppliedConversationSourceIds' \
  scripts/utils/ollamaChat.ts

printf '\n=== CONVERSATION HISTORY PROMPT CONSTRUCTION ===\n'
grep -n -A90 -B40 -E \
  'sourceTurnId|conversation_turn|Conversation history|conversation history|selectedHistory|history\.map|context\.history' \
  scripts/utils/ollamaChat.ts | head -520

printf '\n=== SUPPORT REFERENCE PROMPT RULES ===\n'
grep -n -A80 -B35 -E \
  'supportSourceReferences|support source|support reference|conversation_turn|project_context_excerpt' \
  scripts/utils/ollamaChat.ts | head -620

printf '\n=== ACTIVE CONVERSATION TURN COUNT ===\n'
sqlite3 -header -column db/main.db "
SELECT
  c.conversation_id,
  c.project_id,
  c.turn_count,
  COUNT(t.turn_id) AS persisted_turn_count
FROM matilda_conversations c
LEFT JOIN matilda_conversation_turns t
  ON t.project_id = c.project_id
 AND t.conversation_id = c.conversation_id
WHERE c.conversation_id = 'matilda-conversation-hq-1787159584712-q6x7o3'
GROUP BY
  c.conversation_id,
  c.project_id,
  c.turn_count;
" || true

printf '\n=== ACTUAL SUPPLIABLE TURN IDENTITIES ===\n'
sqlite3 -header -column db/main.db "
SELECT
  turn_id,
  project_id,
  conversation_id,
  created_at
FROM matilda_conversation_turns
WHERE project_id = 'hq'
  AND conversation_id = 'matilda-conversation-hq-1787159584712-q6x7o3'
ORDER BY rowid ASC;
" || true

printf '\n=== EXISTING EMPTY-HISTORY TEST COVERAGE ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
  -E 'empty history|history: \[\]|conversation_turn|supportSourceReferences.*\[\]|sourceTurnId' \
  scripts server routes db 2>/dev/null | head -420

printf '\n=== DETERMINATION INPUTS ===\n'
printf '%s\n' \
  'IF_PERSISTED_TURN_COUNT_ZERO=VALID_CONVERSATION_SUPPORT_SET_IS_EMPTY' \
  'IF_PROMPT_STILL_PERMITS_CONVERSATION_TURN_REFERENCES_WITH_EMPTY_SET=PROMPT_CONSTRAINT_GAP' \
  'IF_PROMPT_EXPLICITLY_FORBIDS_UNSUPPLIED_REFERENCES=MODEL_CONTRACT_NONCOMPLIANCE' \
  'CURRENT_TURN_IS_NOT_PRIOR_CONVERSATION_SUPPORT=YES' \
  'FAIL_CLOSED_VALIDATION_MUST_REMAIN=YES' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'GENERATION_POLICY_CHANGE_AUTHORIZED=NO' \
  'FIX_AUTHORIZED=NO' \
  'NEXT_ACTION=CLASSIFY_EMPTY_HISTORY_PROMPT_AND_SUPPLY_ALIGNMENT_FROM_OUTPUT'

printf '\n=== WORKTREE ===\n'
git status --short
