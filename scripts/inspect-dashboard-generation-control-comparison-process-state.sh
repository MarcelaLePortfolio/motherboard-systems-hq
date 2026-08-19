#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=6a61d3b4' \
  'ISSUE_RESOLVED=NO' \
  'UNSEEDED_ARM_COMPLETE=YES' \
  'CONTROLLED_ARM_COMPLETE=UNKNOWN' \
  'ACTION=INSPECT_EXISTING_COMPARISON_PROCESS_ONLY'

printf '\n=== ACTIVE COMPARISON PROCESSES ===\n'
pgrep -af 'run-dashboard-generation-control-comparison|tsx' || true

printf '\n=== RUNNER WORKTREE STATE ===\n'
git status --short -- scripts/run-dashboard-generation-control-comparison.ts

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'START_NEW_EXPERIMENT=NO' \
  'PRODUCTION_CHANGE=NO' \
  'VALIDATOR_CHANGE=NO' \
  'NEXT_ACTION=USE_PROCESS_STATE_TO_DETERMINE_WHETHER_EXISTING_CONTROLLED_ARM_IS_STILL_RUNNING_OR_REQUIRES_BOUNDED_RECOVERY'
