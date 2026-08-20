#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT="docs/checkpoints/MATILDA_UI_503_POST_CHANGE_OLLAMA_VALIDATION_RESULT.txt"

printf '%s\n' \
  'ACTION=CHECK_POST_CHANGE_OLLAMA_VALIDATION_PROGRESS' \
  'NEW_OLLAMA_INVOCATION=NO'

printf '\n=== VALIDATION PROCESS ===\n'
pgrep -af 'run-dashboard-post-change-single-validation|run-authorized-post-change-ollama-validation|tsx' || true

printf '\n=== OLLAMA STATE ===\n'
ollama ps || true

printf '\n=== PARTIAL RESULT ===\n'
if [[ -f "$RESULT" ]]; then
  tail -120 "$RESULT"
else
  echo 'RESULT_FILE_NOT_YET_CREATED'
fi

printf '\n=== CLASSIFICATION ===\n'
if pgrep -f 'run-dashboard-post-change-single-validation' >/dev/null 2>&1; then
  printf '%s\n' \
    'POST_CHANGE_VALIDATION_PROCESS_ACTIVE=YES' \
    'POST_CHANGE_VALIDATION_COMPLETE=NO' \
    'NEXT_ACTION=ALLOW_CURRENT_AUTHORIZED_INVOCATION_TO_RETURN'
else
  printf '%s\n' \
    'POST_CHANGE_VALIDATION_PROCESS_ACTIVE=NO' \
    'NEXT_ACTION=CLASSIFY_EXISTING_RESULT_WITHOUT_STARTING_ANOTHER_INVOCATION'
fi

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'SECOND_OLLAMA_INVOCATION_STARTED=NO' \
  'DASHBOARD_SMOKE_TEST_STARTED=NO' \
  'PROCESS_TERMINATED=NO'

git status --short
