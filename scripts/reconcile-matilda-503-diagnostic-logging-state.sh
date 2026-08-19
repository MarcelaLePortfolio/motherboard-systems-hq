#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_HEAD=4ebaff45' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_FIX_AUTHORIZED=NO' \
  'KNOWN_TYPECHECK_FAILURE=PRE_EXISTING_ROUTES_ATLAS_WHY_TS2554' \
  'TARGET=VERIFY_Whether_DIAGNOSTIC_RUNTIME_CHANGE_WAS_ACTUALLY_COMMITTED'

printf '\n=== CURRENT HEAD ===\n'
git log -1 --oneline

printf '\n=== WORKFLOW DIAGNOSTIC BLOCK PRESENT ===\n'
grep -n -A24 -B10 \
  'Diagnostic failure details' \
  server/matilda-chat-workflow.ts || true

printf '\n=== FILE COMMIT HISTORY ===\n'
git log --oneline -8 -- server/matilda-chat-workflow.ts

printf '\n=== COMMIT CONTENT CHECK ===\n'
git show --stat --oneline 4ebaff45
git show --name-status --oneline 4ebaff45

printf '\n=== WORKTREE ===\n'
git status --short

printf '\n=== CLASSIFICATION ===\n'
if git grep -q 'Diagnostic failure details' HEAD -- server/matilda-chat-workflow.ts 2>/dev/null; then
  printf '%s\n' \
    'DIAGNOSTIC_LOGGING_PRESENT_IN_HEAD=YES' \
    'RUNTIME_RESTART_REQUIRED_TO_LOAD_CHANGE=YES' \
    'NEXT_ACTION=RESTART_BACKEND_WITH_FRESH_LOG_THEN_REPRODUCE_503'
else
  printf '%s\n' \
    'DIAGNOSTIC_LOGGING_PRESENT_IN_HEAD=NO' \
    'LIKELY_CAUSE=TYPECHECK_ABORTED_INNER_COMMIT_BEFORE_RUNTIME_FILE_WAS_STAGED' \
    'NEXT_ACTION=COMMIT_BOUNDED_RUNTIME_LOGGING_SEPARATELY_BEFORE_RESTART'
fi

printf '%s\n' \
  'TYPECHECK_FAILURE_RELEVANT_TO_THIS_CHANGE=NO' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'GENERATION_POLICY_CHANGE_AUTHORIZED=NO' \
  'FIX_AUTHORIZED=NO'
