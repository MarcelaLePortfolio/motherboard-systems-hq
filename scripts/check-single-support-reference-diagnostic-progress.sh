#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT="docs/checkpoints/MATILDA_UI_503_SUPPORT_REFERENCE_SINGLE_DIAGNOSTIC_RESULT.txt"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'ACTION=CHECK_SINGLE_DIAGNOSTIC_PROGRESS_WITHOUT_INTERRUPTION' \
  'PROCESS_KILL=NO' \
  'NEW_OLLAMA_INVOCATION=NO'

printf '\n=== DIAGNOSTIC PROCESS ===\n'
pgrep -af 'run-dashboard-support-reference-single-diagnostic|run-single-support-reference-diagnostic|tsx' || true

printf '\n=== OLLAMA STATE ===\n'
ollama ps || true

printf '\n=== ACTIVE OLLAMA CONNECTIONS ===\n'
for pid in $(pgrep -f 'run-dashboard-support-reference-single-diagnostic' || true); do
  ps -p "$pid" -o pid=,ppid=,etime=,stat=,command= || true
  lsof -nP -p "$pid" -iTCP 2>/dev/null | grep '11434' || true
done

printf '\n=== PARTIAL RESULT ===\n'
if [[ -f "$RESULT" ]]; then
  tail -80 "$RESULT"
else
  echo 'RESULT_FILE_NOT_YET_CREATED'
fi

printf '\n=== CLASSIFICATION ===\n'
if pgrep -f 'run-dashboard-support-reference-single-diagnostic' >/dev/null 2>&1; then
  printf '%s\n' \
    'DIAGNOSTIC_PROCESS_ACTIVE=YES' \
    'DIAGNOSTIC_COMPLETE=NO' \
    'ACTION_REQUIRED=NONE_YET' \
    'NEXT_ACTION=ALLOW_CURRENT_AUTHORIZED_INVOCATION_TO_RETURN_UNLESS_STALL_OR_TIMEOUT_IS_ESTABLISHED'
else
  printf '%s\n' \
    'DIAGNOSTIC_PROCESS_ACTIVE=NO' \
    'NEXT_ACTION=CLASSIFY_EXISTING_RESULT_OR_TERMINATION_STATE_WITHOUT_STARTING_ANOTHER_INVOCATION'
fi

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'PROCESS_TERMINATED=NO' \
  'RETRY_STARTED=NO' \
  'PRODUCTION_CHANGE=NO' \
  'VALIDATOR_CHANGE=NO'

printf '\n=== WORKTREE ===\n'
git status --short
