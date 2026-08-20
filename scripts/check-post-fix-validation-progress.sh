#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT="docs/checkpoints/MATILDA_UI_503_POST_FIX_SINGLE_VALIDATION_RESULT.txt"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=cca421f1' \
  'ACTION=CHECK_POST_FIX_VALIDATION_PROGRESS_WITHOUT_INTERRUPTION' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PROCESS_KILL=NO'

printf '\n=== VALIDATION PROCESS ===\n'
pgrep -af 'run-dashboard-post-fix-single-validation|run-single-post-fix-validation|tsx' || true

printf '\n=== OLLAMA STATE ===\n'
ollama ps || true

printf '\n=== ACTIVE OLLAMA CONNECTIONS ===\n'
for pid in $(pgrep -f 'run-dashboard-post-fix-single-validation' || true); do
  ps -p "$pid" -o pid=,ppid=,etime=,stat=,command= || true
  lsof -nP -p "$pid" -iTCP 2>/dev/null | grep '11434' || true
done

printf '\n=== PARTIAL RESULT ===\n'
if [[ -f "$RESULT" ]]; then
  tail -100 "$RESULT"
else
  echo 'RESULT_FILE_NOT_YET_CREATED'
fi

printf '\n=== CLASSIFICATION ===\n'
if pgrep -f 'run-dashboard-post-fix-single-validation' >/dev/null 2>&1; then
  printf '%s\n' \
    'POST_FIX_VALIDATION_PROCESS_ACTIVE=YES' \
    'POST_FIX_VALIDATION_COMPLETE=NO' \
    'ACTION_REQUIRED=NONE_YET' \
    'NEXT_ACTION=ALLOW_CURRENT_AUTHORIZED_INVOCATION_TO_RETURN_UNLESS_STALL_OR_TIMEOUT_IS_ESTABLISHED'
else
  printf '%s\n' \
    'POST_FIX_VALIDATION_PROCESS_ACTIVE=NO' \
    'NEXT_ACTION=CLASSIFY_EXISTING_RESULT_OR_TERMINATION_STATE_WITHOUT_STARTING_ANOTHER_INVOCATION'
fi

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'AUTHORIZED_INVOCATION_COUNT=1' \
  'SECOND_INVOCATION_STARTED=NO' \
  'PROCESS_TERMINATED=NO' \
  'PRODUCTION_CHANGE=NO' \
  'VALIDATOR_CHANGE=NO'

printf '\n=== WORKTREE ===\n'
git status --short
