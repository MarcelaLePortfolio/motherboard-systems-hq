#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
RESULT_FILE="PHASE62B_SUCCESS_RATE_LIVE_VALIDATION_RESULT_20260317.md"

echo "== running real runtime validation flow =="
./scripts/_local/phase62b_run_real_success_rate_runtime_validation.sh

LATEST_LOG="$(ls -1t PHASE62B_REAL_RUNTIME_VALIDATION_*.txt | head -n 1)"
echo "latest_validation_log=${LATEST_LOG}"

echo
echo "== operator reminder =="
echo "Open ${RESULT_FILE} and fill these from the live dashboard:"
echo "- initial_success_rate"
echo "- post_success_terminal_success_rate"
echo "- post_failure_terminal_success_rate"
echo "- running_tasks_notes"
echo "- latency_notes"
echo "- layout_notes"
echo "- ownership_notes"
echo
echo "Set final_status=PASS only if all gate conditions are satisfied."
echo "If runtime behavior is unclear, set final_status=FAIL and record blocker findings only."
