#!/usr/bin/env bash
set -euo pipefail

echo "== phase62b next step =="
echo "1) Open dashboard at http://127.0.0.1:8080/dashboard"
echo "2) Note initial Success Rate / Running Tasks / Latency"
echo "3) Run real validation wrapper"
echo

./scripts/_local/phase62b_execute_real_runtime_validation_and_capture_result.sh

echo
echo "== open validation result template =="
open PHASE62B_SUCCESS_RATE_LIVE_VALIDATION_RESULT_20260317.md || true

echo
echo "== latest validation log =="
ls -1t PHASE62B_REAL_RUNTIME_VALIDATION_*.txt | head -n 1
