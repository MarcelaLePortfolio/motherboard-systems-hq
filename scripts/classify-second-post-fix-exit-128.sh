#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT="docs/checkpoints/MATILDA_UI_503_SECOND_POST_FIX_VALIDATION_RESULT.txt"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'ACTION=CLASSIFY_EXIT_CODE_128_WITHOUT_RETRY' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PRODUCTION_CHANGE=NO'

printf '\n=== RESULT FILE STATE ===\n'
if [[ -f "$RESULT" ]]; then
  ls -lh "$RESULT"
  tail -120 "$RESULT"
else
  echo 'RESULT_FILE_MISSING=YES'
fi

printf '\n=== GIT STATE ===\n'
git status --short
git log -5 --oneline

printf '\n=== SECOND VALIDATION SCRIPT STATE ===\n'
ls -l scripts/run-second-post-fix-validation.sh 2>/dev/null || true
grep -nE 'exit|git add|git commit|git push|npx tsx|VALIDATION_STATUS|RUN_STATUS' \
  scripts/run-second-post-fix-validation.sh 2>/dev/null || true

printf '\n=== CLASSIFICATION ===\n'
printf '%s\n' \
  'EXIT_CODE_128_OBSERVED=YES' \
  'EXIT_128_CAUSE_NOT_YET_ESTABLISHED=YES' \
  'SECOND_VALIDATION_RESULT_PRESERVED_IF_PRESENT=YES' \
  'THIRD_INVOCATION_AUTHORIZED=NO' \
  'NEXT_ACTION=USE_RESULT_AND_GIT_STATE_TO_DISTINGUISH_VALIDATION_FAILURE_FROM_GIT_OR_SHELL_WRAPPER_FAILURE'

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'RETRY_STARTED=NO' \
  'OLLAMA_INVOCATION_STARTED=NO' \
  'VALIDATOR_CHANGE=NO' \
  'TIMEOUT_CHANGE=NO'

printf '\n=== WORKTREE ===\n'
git status --short
