#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE87_14_PRINT_WRAPPER_SMOKE_EVIDENCE.txt"
SIGNALS_JSON='{"stability":"stable","executionRisk":"none","cognition":"consistent","signalCoherence":"coherent","operatorAttention":"none"}'

{
  echo "PHASE 87.14 PRINT WRAPPER SMOKE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"

  ./scripts/phase87_14_print_situation_summary.sh "$SIGNALS_JSON"

  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"
