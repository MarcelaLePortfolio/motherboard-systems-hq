#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=79f38be7' \
  'ISSUE_RESOLVED=NO' \
  'UNSEEDED_ARM_COMPLETE=YES' \
  'CONTROLLED_ARM_COMPLETE=UNKNOWN' \
  'ACTION=INSPECT_EXISTING_TERMINAL_OUTPUT_PROGRESS_ONLY'

printf '\n=== ACTIVE COMPARISON PROCESS ===\n'
pgrep -af 'run-dashboard-generation-control-comparison|tsx' || true

printf '\n=== TTY OUTPUT POSITION ===\n'
for pid in 71361 71372 71378; do
  if ps -p "$pid" >/dev/null 2>&1; then
    echo "--- PID $pid ---"
    lsof -p "$pid" 2>/dev/null | grep '/dev/ttys168' || true
  fi
done

printf '\n=== LIVE OLLAMA CONNECTION ===\n'
lsof -nP -p 71378 -iTCP 2>/dev/null | grep '11434' || true
ollama ps || true

printf '\n=== CLASSIFICATION BOUNDARY ===\n'
printf '%s\n' \
  'PROCESS_TERMINATION_AUTHORIZED=NO' \
  'NEW_EXPERIMENT_AUTHORIZED=NO' \
  'PRODUCTION_CHANGE_AUTHORIZED=NO' \
  'VALIDATOR_CHANGE_AUTHORIZED=NO' \
  'EXPECTED_NEXT_EVIDENCE=CONTROLLED_RUN_COMPLETION_OR_FINAL_COMPARISON_SUMMARY_FROM_TTYS168'

printf '\n=== WORKTREE ===\n'
git status --short
