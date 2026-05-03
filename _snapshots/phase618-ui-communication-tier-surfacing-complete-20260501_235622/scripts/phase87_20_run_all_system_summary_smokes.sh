#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE87_20_ALL_SYSTEM_SUMMARY_SMOKES_EVIDENCE.txt"

{
  echo "PHASE 87.20 ALL SYSTEM SUMMARY SMOKES EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"

  echo "RUN: phase87_15_run_system_summary_smoke.sh"
  ./scripts/phase87_15_run_system_summary_smoke.sh
  echo "────────────────────────────────"

  echo "RUN: phase87_17_run_system_summary_cli_smoke.sh"
  ./scripts/phase87_17_run_system_summary_cli_smoke.sh
  echo "────────────────────────────────"

  echo "RUN: phase87_18_run_print_system_summary_wrapper_smoke.sh"
  ./scripts/phase87_18_run_print_system_summary_wrapper_smoke.sh
  echo "────────────────────────────────"

  echo "RUN: phase87_19_run_system_summary_matrix.sh"
  ./scripts/phase87_19_run_system_summary_matrix.sh
  echo "────────────────────────────────"

  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"
