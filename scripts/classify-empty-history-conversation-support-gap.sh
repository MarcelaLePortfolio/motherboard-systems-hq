#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=fc1237c6' \
  'MODE=COLLABORATION_DIAGNOSTIC' \
  'PRODUCTION_CHANGE=NONE' \
  'ISSUE_RESOLVED=NO' \
  'OBSERVED_FAILURE=INVALID_MODEL_AUTHORED_CONVERSATION_SUPPORT_PROVENANCE' \
  'TARGET=CLASSIFY_EMPTY_HISTORY_CONVERSATION_SUPPORT_CONTRACT'

printf '\n=== VALIDATOR CONTRACT ===\n'
sed -n '1040,1132p' scripts/utils/ollamaChat.ts

printf '\n=== PROMPT CONSTRUCTION ===\n'
sed -n '730,930p' scripts/utils/ollamaChat.ts

printf '\n=== ACTIVE CONVERSATION SUPPLY SET ===\n'
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
WHERE c.project_id = 'hq'
  AND c.conversation_id = 'matilda-conversation-hq-1787159584712-q6x7o3'
GROUP BY c.conversation_id, c.project_id, c.turn_count;
" || true

printf '\n=== SUPPLIABLE CONVERSATION SOURCE IDS ===\n'
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

printf '\n=== PROMPT CONVERSATION-SUPPORT CONSTRAINT SEARCH ===\n'
grep -n -E \
  'Conversation source|conversation_turn|supportSourceReferences|support source|support reference|supplied.*conversation|only.*conversation|do not.*conversation' \
  scripts/utils/ollamaChat.ts || true

printf '\n=== CLASSIFICATION ===\n'

PERSISTED_COUNT="$(
  sqlite3 db/main.db "
SELECT COUNT(*)
FROM matilda_conversation_turns
WHERE project_id = 'hq'
  AND conversation_id = 'matilda-conversation-hq-1787159584712-q6x7o3';
" 2>/dev/null || echo UNKNOWN
)"

echo "PERSISTED_TURN_COUNT=$PERSISTED_COUNT"

if [[ "$PERSISTED_COUNT" == "0" ]]; then
  printf '%s\n' \
    'VALID_CONVERSATION_SUPPORT_SET=EMPTY' \
    'CURRENT_USER_MESSAGE_IS_NOT_PRIOR_CONVERSATION_SUPPORT=YES' \
    'MODEL_RETURNED_UNSUPPLIED_CONVERSATION_REFERENCE=CONFIRMED_BY_LIVE_503' \
    'FAIL_CLOSED_VALIDATOR_BEHAVIOR=CORRECT' \
    'VALIDATOR_MALFUNCTION=NOT_ESTABLISHED' \
    'LIKELY_DEFECT_CLASS=PROMPT_OUTPUT_CONSTRAINT_GAP_FOR_EMPTY_CONVERSATION_HISTORY' \
    'SAFE_FIX_DIRECTION=MAKE_ALLOWED_CONVERSATION_SUPPORT_UNIVERSE_EXPLICIT_AND_REQUIRE_EMPTY_CONVERSATION_REFERENCES_WHEN_NO_SOURCE_IDS_ARE_SUPPLIED' \
    'VALIDATOR_WEAKENING=PROHIBITED' \
    'GENERATION_POLICY_CHANGE=NOT_REQUIRED_BY_CURRENT_EVIDENCE' \
    'FIX_IMPLEMENTATION_AUTHORIZED=NO' \
    'NEXT_ACTION=DEFINE_BOUNDED_PROMPT_CONTRACT_FIX_AND_TEST_BOUNDARY'
else
  printf '%s\n' \
    'VALID_CONVERSATION_SUPPORT_SET=NONEMPTY' \
    'EMPTY_HISTORY_HYPOTHESIS=REJECTED' \
    'NEXT_ACTION=COMPARE_MODEL_RETURNED_SOURCE_TURN_ID_WITH_EXACT_SUPPLIED_SOURCE_IDS' \
    'FIX_IMPLEMENTATION_AUTHORIZED=NO'
fi

printf '\n=== WORKTREE ===\n'
git status --short
