#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=1ba4f8a3' \
  'ISSUE_RESOLVED=NO' \
  'UNSEEDED_ARM_COMPLETE=YES' \
  'CONTROLLED_ARM_COMPLETE=UNKNOWN' \
  'ACTION=CAPTURE_EXISTING_COMPARISON_TERMINAL_STATE_WITHOUT_INTERRUPTION'

printf '\n=== ACTIVE COMPARISON PROCESS ===\n'
pgrep -af 'run-dashboard-generation-control-comparison|tsx' || true

printf '\n=== OLLAMA STATE ===\n'
ollama ps || true

printf '\n=== TERMINAL DESCRIPTOR STATE ===\n'
for pid in $(pgrep -f 'run-dashboard-generation-control-comparison|tsx' || true); do
  ps -p "$pid" -o pid=,ppid=,etime=,stat=,command= || true
  lsof -p "$pid" 2>/dev/null | grep '/dev/ttys' || true
done

printf '\n=== CURRENT CLASSIFICATION ===\n'
printf '%s\n' \
  'EXISTING_COMPARISON_WAS_ACTIVE_AND_CONNECTED_TO_OLLAMA=YES' \
  'STALLED_PROCESS_ESTABLISHED=NO' \
  'PROCESS_TERMINATION_JUSTIFIED=NO' \
  'NEW_EXPERIMENT_AUTHORIZED=NO' \
  'PRODUCTION_CHANGE_AUTHORIZED=NO' \
  'NEXT_ACTION=CAPTURE_REMAINING_CONTROLLED_RUN_OUTPUT_AND_FINAL_COMPARISON_SUMMARY_FROM_EXISTING_TERMINAL_SESSION'

printf '\n=== WORKTREE ===\n'
git status --short
