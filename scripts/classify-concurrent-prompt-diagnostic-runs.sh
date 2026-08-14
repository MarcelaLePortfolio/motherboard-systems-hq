#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY CONCURRENT PROMPT DIAGNOSTIC RUNS ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 2440f30c HEAD

echo "=== ACTIVE RUNNER PROCESSES ==="
ps aux | grep 'run-bounded-prompt-presentation-diagnostic.ts' | grep -v grep || true

runner_count="$(ps aux | grep 'run-bounded-prompt-presentation-diagnostic.ts' | grep -v grep | wc -l | tr -d ' ')"
echo "RUNNER_PROCESS_COUNT=$runner_count"

echo "=== DIAGNOSTIC LOGS ==="
ls -lt artifacts/prompt-presentation-diagnostic-*.log 2>/dev/null | head -10 || true

zero_logs="$(find artifacts -maxdepth 1 -name 'prompt-presentation-diagnostic-*.log' -size 0 2>/dev/null | wc -l | tr -d ' ')"
echo "ZERO_BYTE_DIAGNOSTIC_LOG_COUNT=$zero_logs"

cat <<'MAP'
OBSERVED_STATE=
MULTIPLE_CONCURRENT_DIAGNOSTIC_RUNNER_PROCESS_TREES
OLLAMA_REACHABLE=
YES
LATEST_DIAGNOSTIC_LOGS=
ZERO_BYTES
EXPECTED_SINGLE_DIAGNOSTIC_RUN=
VIOLATED_BY_CONCURRENT_INVOCATIONS
CURRENT_RESULTS_INTERPRETABLE=
NO
PRODUCTION_CHANGE=
NONE
SAFE_NEXT_ACTION=
STOP_DUPLICATE_DIAGNOSTIC_RUNNERS_THEN_RESTART_EXACTLY_ONE_CLEAN_RUN
MAP
