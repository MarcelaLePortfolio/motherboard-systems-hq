#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 68 TELEMETRY CONTRACT CHECK"
echo "Drift detection — NON BLOCKING MODE"
echo "-----------------------------------"

CONTRACT_FILE="docs/telemetry/EVENT_SCHEMA_CONTRACT.md"
VALIDATOR_FILE="scripts/_local/phase68_event_schema_validator.ts"
SAMPLE_FILE="scripts/_local/fixtures/telemetry/task_events_contract_sample.json"

if [ ! -f "$CONTRACT_FILE" ]; then
  echo "FAIL: telemetry contract missing"
  exit 1
fi

echo "PASS: telemetry contract present"

if [ ! -f "$VALIDATOR_FILE" ]; then
  echo "FAIL: telemetry validator missing"
  exit 1
fi

echo "PASS: telemetry validator present"

if [ ! -f "$SAMPLE_FILE" ]; then
  echo "FAIL: sample telemetry corpus missing"
  exit 1
fi

echo "PASS: sample telemetry corpus present"

echo
echo "Checking required contract sections..."

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
echo "Running validator against sample telemetry corpus..."

if command -v tsx >/dev/null 2>&1; then
  tsx "$VALIDATOR_FILE" "$(cat "$SAMPLE_FILE")"
elif command -v pnpm >/dev/null 2>&1; then
  pnpm exec tsx "$VALIDATOR_FILE" "$(cat "$SAMPLE_FILE")"
elif command -v npx >/dev/null 2>&1; then
  npx tsx "$VALIDATOR_FILE" "$(cat "$SAMPLE_FILE")"
else
  echo "FAIL: tsx runtime not available"
  exit 1
fi

echo
echo "Phase 68 contract baseline verified."

exit 0
