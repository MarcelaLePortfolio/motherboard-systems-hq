#!/usr/bin/env bash
set -euo pipefail

echo "== phase62b rerun after run_id fix =="
echo "1) Open dashboard at http://127.0.0.1:8080/dashboard"
echo "2) Note initial Success Rate / Running Tasks / Latency"
echo

./scripts/_local/phase62b_execute_real_runtime_validation_and_capture_result.sh

echo
echo "== latest validation log =="
LATEST_LOG="$(ls -1t PHASE62B_REAL_RUNTIME_VALIDATION_*.txt | head -n 1)"
echo "${LATEST_LOG}"

echo
echo "== open result template =="
open PHASE62B_SUCCESS_RATE_LIVE_VALIDATION_RESULT_20260317.md || true

echo
echo "If terminal routes now succeed, record dashboard observations in:"
echo "PHASE62B_SUCCESS_RATE_LIVE_VALIDATION_RESULT_20260317.md"
