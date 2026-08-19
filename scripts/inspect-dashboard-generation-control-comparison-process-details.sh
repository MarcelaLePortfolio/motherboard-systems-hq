#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=adb9746e' \
  'ISSUE_RESOLVED=NO' \
  'UNSEEDED_ARM_COMPLETE=YES' \
  'CONTROLLED_ARM_COMPLETE=UNKNOWN' \
  'ACTION=INSPECT_EXISTING_PROCESS_DETAILS_ONLY'

printf '\n=== MATCHED PROCESS DETAILS ===\n'
for pid in $(pgrep -f 'run-dashboard-generation-control-comparison|tsx' || true); do
  ps -p "$pid" -o pid=,ppid=,etime=,stat=,command= || true
done

printf '\n=== PROCESS TREE ===\n'
ps -axo pid,ppid,etime,stat,command | \
  grep -E 'run-dashboard-generation-control-comparison|tsx|ollama' | \
  grep -v grep || true

printf '\n=== RUNNER WORKTREE STATE ===\n'
git status --short -- scripts/run-dashboard-generation-control-comparison.ts

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'START_NEW_EXPERIMENT=NO' \
  'KILL_PROCESS=NO' \
  'PRODUCTION_CHANGE=NO' \
  'VALIDATOR_CHANGE=NO' \
  'NEXT_ACTION=CLASSIFY_WHETHER_EXISTING_CONTROLLED_ARM_IS_ACTIVE_STALLED_OR_TERMINATED_FROM_PROCESS_DETAILS'
