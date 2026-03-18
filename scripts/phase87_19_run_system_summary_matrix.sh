#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE87_19_SYSTEM_SUMMARY_MATRIX_EVIDENCE.txt"

TMP_STABLE="$(mktemp)"
TMP_DEGRADED="$(mktemp)"
TMP_UNKNOWN="$(mktemp)"

cleanup() {
  rm -f "$TMP_STABLE" "$TMP_DEGRADED" "$TMP_UNKNOWN"
}

trap cleanup EXIT

cat > "$TMP_STABLE" << 'JSON'
{"stability":"stable","executionRisk":"none","cognition":"consistent","signalCoherence":"coherent","operatorAttention":"none"}
JSON

cat > "$TMP_DEGRADED" << 'JSON'
{"stability":"degraded","executionRisk":"elevated","cognition":"mixed","signalCoherence":"divergent","operatorAttention":"required"}
JSON

cat > "$TMP_UNKNOWN" << 'JSON'
{}
JSON

{
  echo "PHASE 87.19 SYSTEM SUMMARY MATRIX EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "────────────────────────────────"

  echo "CASE: STABLE"
  ./scripts/phase87_18_print_system_situation_summary.sh --file "$TMP_STABLE"
  echo "────────────────────────────────"

  echo "CASE: DEGRADED"
  ./scripts/phase87_18_print_system_situation_summary.sh --file "$TMP_DEGRADED"
  echo "────────────────────────────────"

  echo "CASE: UNKNOWN"
  ./scripts/phase87_18_print_system_situation_summary.sh --file "$TMP_UNKNOWN"
  echo "────────────────────────────────"

  echo "RESULT: PASS"
} | tee "$OUTPUT_FILE"
