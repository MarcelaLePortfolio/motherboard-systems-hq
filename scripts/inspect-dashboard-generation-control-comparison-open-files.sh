#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=a2b7e91b' \
  'ISSUE_RESOLVED=NO' \
  'UNSEEDED_ARM_COMPLETE=YES' \
  'CONTROLLED_ARM_COMPLETE=UNKNOWN' \
  'ACTION=INSPECT_ACTIVE_COMPARISON_FILE_DESCRIPTORS_ONLY'

printf '\n=== ACTIVE COMPARISON PROCESS ===\n'
ps -p 71361,71372,71378 -o pid=,ppid=,etime=,stat=,command= || true

printf '\n=== OPEN FILES / DESCRIPTORS ===\n'
for pid in 71361 71372 71378; do
  if ps -p "$pid" >/dev/null 2>&1; then
    echo "--- PID $pid ---"
    lsof -p "$pid" 2>/dev/null | \
      grep -E 'cwd|txt|REG|PIPE|CHR|IPv4|IPv6' || true
  fi
done

printf '\n=== OLLAMA CONNECTIONS ===\n'
lsof -nP -iTCP -sTCP:ESTABLISHED 2>/dev/null | \
  grep -E 'ollama|node|71378|71392' || true

printf '\n=== CLASSIFICATION BOUNDARY ===\n'
printf '%s\n' \
  'PROCESS_TERMINATION_AUTHORIZED=NO' \
  'NEW_EXPERIMENT_AUTHORIZED=NO' \
  'PRODUCTION_CHANGE_AUTHORIZED=NO' \
  'VALIDATOR_CHANGE_AUTHORIZED=NO' \
  'NEXT_ACTION=DETERMINE_FROM_OPEN_DESCRIPTORS_AND_CONNECTIONS_WHETHER_CONTROLLED_RUN_IS_BLOCKED_ON_OLLAMA_OR_HAS_LOST_OUTPUT_PROGRESS'

printf '\n=== WORKTREE ===\n'
git status --short -- scripts/run-dashboard-generation-control-comparison.ts
