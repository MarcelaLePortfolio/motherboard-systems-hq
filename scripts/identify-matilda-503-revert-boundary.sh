#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=8b64bd72' \
  'ISSUE_RESOLVED=NO' \
  'MODE=COLLABORATION_ROLLBACK_CLASSIFICATION' \
  'REVERT_EXECUTED=NO' \
  'TARGET=IDENTIFY_EXACT_PRE_FIX_STABLE_RUNTIME_BOUNDARY'

printf '\n=== EMPTY-HISTORY FIX COMMITS ===\n'
git show --stat --oneline 48e1505b
git show --stat --oneline 1b601131

printf '\n=== PRE-FIX GATE ===\n'
git show --stat --oneline 09342faa

printf '\n=== TARGET FILE HISTORY ===\n'
git log --oneline --decorate -12 -- scripts/utils/ollamaChat.ts

printf '\n=== PRE-FIX VS FIX DIFF ===\n'
git diff 09342faa..48e1505b -- scripts/utils/ollamaChat.ts

printf '\n=== CURRENT VS PRE-FIX TARGET FILE DIFF ===\n'
git diff 09342faa..HEAD -- scripts/utils/ollamaChat.ts

printf '\n=== CLASSIFICATION ===\n'
if git merge-base --is-ancestor 09342faa 48e1505b; then
  printf '%s\n' \
    'PRE_FIX_RUNTIME_COMMIT=09342faa' \
    'FIRST_PROMPT_FIX_COMMIT=48e1505b' \
    'FIX_RUNNER_COMMIT=1b601131' \
    'REVERT_RUNTIME_TARGET=RESTORE_scripts/utils/ollamaChat.ts_FROM_09342faa' \
    'FULL_BRANCH_RESET_REQUIRED=NO' \
    'DIAGNOSTIC_HISTORY_CAN_REMAIN=YES' \
    'PRODUCTION_RUNTIME_REVERT_SCOPE=ONE_FILE' \
    'REVERT_READY=YES'
else
  printf '%s\n' \
    'REVERT_BOUNDARY_VERIFICATION=FAILED' \
    'REVERT_READY=NO'
  exit 1
fi

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'REVERT_EXECUTED=NO' \
  'VALIDATOR_CHANGE=NO' \
  'GENERATION_POLICY_CHANGE=NO' \
  'MODEL_CHANGE=NO' \
  'RETRY_CHANGE=NO' \
  'TIMEOUT_CHANGE=NO' \
  'PERSISTENCE_CHANGE=NO' \
  'NEXT_ACTION=RESTORE_ONLY_OLLAMACHAT_TS_FROM_VERIFIED_PRE_FIX_COMMIT'

printf '\n=== WORKTREE ===\n'
git status --short
