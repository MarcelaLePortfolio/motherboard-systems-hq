#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE87_18_PRINT_SYSTEM_SUMMARY_WRAPPER_SMOKE_EVIDENCE.txt"
TMP_JSON_FILE="$(mktemp)"

cleanup() {
  rm -f "$TMP_JSON_FILE"
}

trap cleanup EXIT

cat > "$TMP_JSON_FILE" << 'JSON'
{"stability":"stable","executionRisk":"none","cognition":"consistent","signalCoherence":"coherent","operatorAttention":"none"}
JSON

{
  echo "PHASE 87.18 PRINT SYSTEM SUMMARY WRAPPER SMOKE EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"

  npx tsx scripts/phase87_17_system_situation_summary_cli.ts --file "$TMP_JSON_FILE"
  ./scripts/phase87_18_print_system_situation_summary.sh --file "$TMP_JSON_FILE"

  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"
