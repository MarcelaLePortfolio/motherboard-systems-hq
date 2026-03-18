#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE87_14_PRINT_WRAPPER_SMOKE_EVIDENCE.txt"
TMP_JSON_FILE="$(mktemp)"

cat > "$TMP_JSON_FILE" << 'JSON'
{"stability":"stable","executionRisk":"none","cognition":"consistent","signalCoherence":"coherent","operatorAttention":"none"}
JSON

{
  echo "PHASE 87.14 PRINT WRAPPER SMOKE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"

  ./scripts/phase87_14_print_situation_summary.sh "$(cat "$TMP_JSON_FILE")"

  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"

rm -f "$TMP_JSON_FILE"
