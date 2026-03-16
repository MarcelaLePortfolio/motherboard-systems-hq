#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 68 TELEMETRY CONTRACT CHECK"
echo "Drift detection — NON BLOCKING MODE"
echo "-----------------------------------"

CONTRACT_FILE="docs/telemetry/EVENT_SCHEMA_CONTRACT.md"

if [ ! -f "$CONTRACT_FILE" ]; then
  echo "FAIL: telemetry contract missing"
  exit 1
fi

echo "PASS: telemetry contract present"

echo
echo "Checking required sections..."

grep -q "TASK EVENT CANONICAL SCHEMA" "$CONTRACT_FILE" \
  && echo "PASS: task schema defined" \
  || echo "WARN: task schema missing"

grep -q "DRIFT CONDITIONS" "$CONTRACT_FILE" \
  && echo "PASS: drift conditions defined" \
  || echo "WARN: drift conditions missing"

grep -q "VALIDATION RULES" "$CONTRACT_FILE" \
  && echo "PASS: validation rules defined" \
  || echo "WARN: validation rules missing"

echo
echo "Phase 68 contract baseline verified."

exit 0
