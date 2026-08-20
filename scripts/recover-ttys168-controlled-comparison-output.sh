#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=4d6c6deb' \
  'ISSUE_RESOLVED=NO' \
  'ACTION=ATTEMPT_DIRECT_TTYS168_OUTPUT_RECOVERY_ONLY'

printf '\n=== TERMINAL DEVICE STATE ===\n'
ls -l /dev/ttys168 2>/dev/null || true
who | grep 'ttys168' || true

printf '\n=== SHELL HISTORY SEARCH ===\n'
HISTFILE_PATH="${HISTFILE:-$HOME/.zsh_history}"
if [[ -f "$HISTFILE_PATH" ]]; then
  grep -nE \
    'run-dashboard-generation-control-comparison|CONTROLLED RUN|COMPARISON SUMMARY|ACCEPTANCE BOUNDARY' \
    "$HISTFILE_PATH" | tail -80 || true
fi

printf '\n=== TERMINAL SAVED-STATE SEARCH ===\n'
find "$HOME/Library" \
  -maxdepth 5 \
  -type f \
  \( -name '*.history' -o -name '*.log' -o -name '*.txt' \) \
  -print0 2>/dev/null |
while IFS= read -r -d '' file; do
  if grep -qE \
    'CONTROLLED RUN 1/10|run-dashboard-generation-control-comparison' \
    "$file" 2>/dev/null; then
    echo "CANDIDATE=$file"
    grep -nE \
      'CONTROLLED RUN|COMPARISON SUMMARY|ACCEPTANCE BOUNDARY|PRIMARY_CONTROL_CRITERION|COMPARATIVE_CRITERION' \
      "$file" 2>/dev/null | tail -80 || true
  fi
done

printf '\n=== RECOVERY CLASSIFICATION ===\n'
printf '%s\n' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PROCESS_RESTART=NO' \
  'PRODUCTION_CHANGE=NO' \
  'VALIDATOR_CHANGE=NO' \
  'NEXT_ACTION=CLASSIFY_WHETHER_ORIGINAL_CONTROLLED_OUTPUT_WAS_RECOVERABLE_FROM_HISTORY_OR_SAVED_TERMINAL_STATE'

printf '\n=== WORKTREE ===\n'
git status --short
