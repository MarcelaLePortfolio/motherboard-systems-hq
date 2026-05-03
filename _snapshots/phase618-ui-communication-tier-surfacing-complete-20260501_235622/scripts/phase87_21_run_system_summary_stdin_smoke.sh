#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE87_21_SYSTEM_SUMMARY_STDIN_SMOKE_EVIDENCE.txt"
SIGNALS_JSON='{"stability":"stable","executionRisk":"none","cognition":"consistent","signalCoherence":"coherent","operatorAttention":"none"}'

{
  echo "PHASE 87.21 SYSTEM SUMMARY STDIN SMOKE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"

  echo "CLI STDIN:"
  printf '%s\n' "$SIGNALS_JSON" | npx tsx scripts/phase87_17_system_situation_summary_cli.ts --stdin
  echo "────────────────────────────────"

  echo "WRAPPER STDIN:"
  printf '%s\n' "$SIGNALS_JSON" | ./scripts/phase87_18_print_system_situation_summary.sh --stdin
  echo "────────────────────────────────"

  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"
