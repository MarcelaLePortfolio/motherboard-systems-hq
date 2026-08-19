#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE='server/matilda-chat-workflow.ts'

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=72373a49' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_FIX_AUTHORIZED=NO' \
  'KNOWN=DIAGNOSTIC_LOGGING_PRESENT_IN_WORKTREE_BUT_NOT_HEAD' \
  'KNOWN_TYPECHECK_FAILURE=PRE_EXISTING_ROUTES_ATLAS_WHY_TS2554' \
  'TARGET=COMMIT_ONLY_THE_BOUNDED_DIAGNOSTIC_RUNTIME_CHANGE'

printf '\n=== VERIFY EXACT DIFF ===\n'
git diff -- "$FILE"

printf '\n=== VERIFY CHANGE BOUNDARY ===\n'
git diff -- "$FILE" | grep -E \
  'Diagnostic failure details|workflowError\.name|workflowError\.message|workflowError\.stack|MatildaConversationWorkflowUnavailableError' || true

printf '\n=== VERIFY NO OTHER RUNTIME FILES MODIFIED ===\n'
git status --short

printf '\n=== COMMIT DIAGNOSTIC RUNTIME CHANGE ===\n'
git add "$FILE"
git commit -m "Add bounded Matilda 503 diagnostic logging"
git push

printf '\n=== VERIFY COMMITTED STATE ===\n'
git grep -n 'Diagnostic failure details' HEAD -- "$FILE"
git status --short

printf '\n=== NEXT STATE ===\n'
printf '%s\n' \
  'DIAGNOSTIC_LOGGING_COMMITTED=YES' \
  'RUNTIME_RESTART_REQUIRED=YES' \
  'ISSUE_RESOLVED=NO' \
  'NEXT_ACTION=RESTART_BACKEND_WITH_FRESH_LOG_AND_REPRODUCE_503_TO_CAPTURE_ROOT_EXCEPTION'
