#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=29dc6652' \
  'MODE=COLLABORATION_DIAGNOSTIC' \
  'ISSUE_RESOLVED=NO' \
  'PREVIOUS_HYPOTHESIS=EMPTY_HISTORY_CONVERSATION_SUPPORT_GAP' \
  'PREVIOUS_FIX_RESULT=ORIGINAL_CONVERSATION_SUPPORT_REJECTION_NOT_REPRODUCED' \
  'NEW_FAILURE=SELECTED_CONTEXT_SEGMENT_NOT_SUPPLIED' \
  'FIX_AUTHORIZED=NO' \
  'TARGET=CLASSIFY_NEW_FAILURE_WITHOUT_LAYERING_ANOTHER_FIX'

printf '\n=== EXACT SELECTED-SEGMENT VALIDATOR ===\n'
sed -n '990,1070p' scripts/utils/ollamaChat.ts

printf '\n=== SELECTED SEGMENT SUPPLY CONSTRUCTION ===\n'
grep -n -A70 -B40 -E \
  'suppliedSegmentByIdentity|projectContextSegmentCandidates|selectedContextSegments' \
  scripts/utils/ollamaChat.ts | head -420

printf '\n=== WORKFLOW PROJECT CONTEXT INPUT ===\n'
sed -n '185,230p' server/matilda-chat-workflow.ts

printf '\n=== PROJECT CONTEXT RETRIEVAL AND SEGMENTATION CALL SITES ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
  -E 'projectContextSegmentCandidates|segment.*candidate|selectedContextSegments|projectContextExcerpts' \
  server scripts routes 2>/dev/null | head -420

printf '\n=== LIVE FAILURE LOG ===\n'
grep -n -A35 -B15 -E \
  'selected context segment that was not supplied|Conversational response failed|Diagnostic failure details' \
  /private/tmp/motherboard-matilda-empty-history-fix-validation.log || true

printf '\n=== CLASSIFICATION BOUNDARY ===\n'
printf '%s\n' \
  'ORIGINAL_CONVERSATION_SUPPORT_REJECTION_AFTER_FIX=NOT_OBSERVED' \
  'NEW_FAIL_CLOSED_REJECTION=SELECTED_CONTEXT_SEGMENT_NOT_SUPPLIED' \
  'VALIDATOR_MALFUNCTION_ESTABLISHED=NO' \
  'MODEL_OUTPUT_CONTRACT_VIOLATION_ESTABLISHED=YES' \
  'CURRENT_FAILURE_CLASS=INVALID_MODEL_AUTHORED_SELECTED_CONTEXT_SEGMENT' \
  'SAFE_NEXT_STEP=COMPARE_EXACT_SUPPLIED_SEGMENT_IDENTITIES_WITH_PROMPT_PRESENTATION_AND_MODEL_OUTPUT' \
  'VALIDATOR_WEAKENING=PROHIBITED' \
  'GENERATION_POLICY_CHANGE=NOT_AUTHORIZED' \
  'NEW_FIX_AUTHORIZED=NO' \
  'THREE_FAILED_ATTEMPTS_FOR_SAME_HYPOTHESIS=NO' \
  'NEXT_ACTION=LOCALIZE_SELECTED_SEGMENT_IDENTITY_MISMATCH_BEFORE_ANY_SECOND_FIX'

printf '\n=== WORKTREE ===\n'
git status --short
