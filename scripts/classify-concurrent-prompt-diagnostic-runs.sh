#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY CONCURRENT PROMPT DIAGNOSTIC RUNS ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 2440f30c HEAD

runner_processes="$(ps aux | grep 'run-bounded-prompt-presentation-diagnostic.ts' | grep -v grep || true)"

echo "=== ACTIVE RUNNER PROCESSES ==="
if [[ -n "$runner_processes" ]]; then
  printf '%s\n' "$runner_processes"
else
  echo "NONE"
fi

runner_count="$(printf '%s\n' "$runner_processes" | grep -c 'run-bounded-prompt-presentation-diagnostic.ts' || true)"
zero_logs="$(find artifacts -maxdepth 1 -name 'prompt-presentation-diagnostic-*.log' -size 0 2>/dev/null | wc -l | tr -d ' ')"

echo "RUNNER_PROCESS_COUNT=$runner_count"
echo "ZERO_BYTE_DIAGNOSTIC_LOG_COUNT=$zero_logs"

if [[ "$runner_count" -eq 0 ]]; then
  cat <<'MAP'
OBSERVED_STATE=
NO_ACTIVE_DIAGNOSTIC_RUNNERS
CURRENT_RESULTS_INTERPRETABLE=
NO
PRODUCTION_CHANGE=
NONE
SAFE_NEXT_ACTION=
START_EXACTLY_ONE_CLEAN_DIAGNOSTIC_RUN
MAP
else
  cat <<MAP
OBSERVED_STATE=
DIAGNOSTIC_RUNNER_STILL_ACTIVE
RUNNER_PROCESS_COUNT=
${runner_count}
CURRENT_RESULTS_INTERPRETABLE=
PENDING
PRODUCTION_CHANGE=
NONE
SAFE_NEXT_ACTION=
DO_NOT_START_ANOTHER_RUN
MAP
fi
