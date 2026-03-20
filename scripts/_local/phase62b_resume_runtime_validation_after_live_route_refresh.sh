#!/usr/bin/env bash
set -euo pipefail

echo "== phase62b resume runtime validation =="
echo "1) verify live create route now surfaces run_id"
./scripts/_local/phase62b_verify_live_create_route_and_restart_runtime.sh

echo
echo "2) rerun real runtime validation"
./scripts/_local/phase62b_rerun_runtime_validation_after_run_id_fix.sh

echo
echo "3) latest artifacts"
ls -1t PHASE62B_LIVE_CREATE_ROUTE_RESTART_CHECK_*.txt 2>/dev/null | head -n 1 || true
ls -1t PHASE62B_LIVE_CREATE_ROUTE_RESTART_SUMMARY_*.md 2>/dev/null | head -n 1 || true
ls -1t PHASE62B_REAL_RUNTIME_VALIDATION_*.txt 2>/dev/null | head -n 1 || true

echo
echo "4) open validation result template"
open PHASE62B_SUCCESS_RATE_LIVE_VALIDATION_RESULT_20260317.md || true
