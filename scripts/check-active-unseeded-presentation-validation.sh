#!/usr/bin/env bash
set -euo pipefail

echo "=== CHECK ACTIVE UNSEEDED PRESENTATION VALIDATION ==="

runner_processes="$(ps aux | grep 'run-bounded-unseeded-experimental-presentation-validation.ts' | grep -v grep || true)"

if [[ -n "$runner_processes" ]]; then
  echo "VALIDATION_RUNNER_ACTIVE=YES"
  printf '%s\n' "$runner_processes"
else
  echo "VALIDATION_RUNNER_ACTIVE=NO"
fi

latest="$(ls -t artifacts/unseeded-experimental-presentation-validation-*.log 2>/dev/null | head -1 || true)"

if [[ -z "$latest" ]]; then
  echo "VALIDATION_LOG=ABSENT"
  echo "CURRENT_RESULT=PENDING_OR_UNCAPTURED"
else
  echo "VALIDATION_LOG=$latest"
  echo "VALIDATION_LOG_BYTES=$(wc -c < "$latest" | tr -d ' ')"

  if grep -q '^RUN_COUNT=10$' "$latest"; then
    echo "VALIDATION_RESULT_COMPLETE=YES"
    grep -E '^(RUN_COUNT=|SEMANTIC_PASSES=|UNSUPPLIED_SUPPORT_FAILURES=|FAIL_CLOSED_OR_RUNTIME_REJECTIONS=|UNIQUE_EXACT_OUTPUT_FINGERPRINTS=|PRODUCTION_CHANGE=)' "$latest"
    echo "NEXT_ACTION=CLASSIFY_BOUNDED_UNSEEDED_PRESENTATION_VALIDATION_RESULTS"
  else
    echo "VALIDATION_RESULT_COMPLETE=NO"
    echo "NEXT_ACTION=DO_NOT_START_ANOTHER_RUN"
  fi
fi

echo "PRODUCTION_CHANGE=NONE"
