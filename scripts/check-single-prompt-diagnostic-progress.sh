#!/usr/bin/env bash
set -euo pipefail

echo "=== CHECK SINGLE PROMPT DIAGNOSTIC PROGRESS ==="

runner_processes="$(ps aux | grep 'run-bounded-prompt-presentation-diagnostic.ts' | grep -v grep || true)"
latest="$(ls -t artifacts/prompt-presentation-diagnostic-single-*.log 2>/dev/null | head -1 || true)"

if [[ -n "$runner_processes" ]]; then
  echo "DIAGNOSTIC_RUNNER_ACTIVE=YES"
  printf '%s\n' "$runner_processes"
else
  echo "DIAGNOSTIC_RUNNER_ACTIVE=NO"
fi

if [[ -z "$latest" ]]; then
  echo "DIAGNOSTIC_LOG=ABSENT"
  echo "CURRENT_RESULT=NOT_INTERPRETABLE"
  echo "NEXT_ACTION=INVESTIGATE_SINGLE_RUN_STOP"
  exit 0
fi

bytes="$(wc -c < "$latest" | tr -d ' ')"
echo "DIAGNOSTIC_LOG=$latest"
echo "DIAGNOSTIC_LOG_BYTES=$bytes"

if grep -q '^TOTAL_RUNS=20$' "$latest"; then
  echo "DIAGNOSTIC_RESULT_COMPLETE=YES"
  grep -E '^(FIXED_SEED=|PAIR_COUNT=|TOTAL_RUNS=|CONTROL_|EXPERIMENTAL_|PRODUCTION_CHANGE=)' "$latest"
  echo "NEXT_ACTION=CLASSIFY_PROMPT_PRESENTATION_DIAGNOSTIC_RESULTS"
elif [[ -n "$runner_processes" ]]; then
  echo "DIAGNOSTIC_RESULT_COMPLETE=NO"
  echo "CURRENT_STATE=SINGLE_RUN_STILL_EXECUTING"
  echo "NEXT_ACTION=WAIT_AND_DO_NOT_START_ANOTHER_RUN"
else
  echo "DIAGNOSTIC_RESULT_COMPLETE=NO"
  echo "CURRENT_STATE=SINGLE_RUN_STOPPED_WITHOUT_COMPLETE_RESULT"
  echo "NEXT_ACTION=INVESTIGATE_SINGLE_RUN_STOP_BEFORE_ANY_RETRY"
fi

echo "PRODUCTION_CHANGE=NONE"
