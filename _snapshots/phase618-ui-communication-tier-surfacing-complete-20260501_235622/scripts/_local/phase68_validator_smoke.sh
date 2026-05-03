#!/usr/bin/env bash
set -euo pipefail

VALIDATOR_FILE="scripts/_local/phase68_event_schema_validator.ts"
VALID_SAMPLE="scripts/_local/fixtures/telemetry/task_events_contract_sample.json"
INVALID_SAMPLE="scripts/_local/fixtures/telemetry/task_events_contract_invalid_sample.json"

echo "PHASE 68 VALIDATOR SMOKE"
echo "------------------------"

if [ ! -f "$VALIDATOR_FILE" ]; then
  echo "FAIL: validator file missing"
  exit 1
fi

if [ ! -f "$VALID_SAMPLE" ]; then
  echo "FAIL: valid sample missing"
  exit 1
fi

if [ ! -f "$INVALID_SAMPLE" ]; then
  echo "FAIL: invalid sample missing"
  exit 1
fi

run_validator() {
  local sample_file="$1"

  if command -v tsx >/dev/null 2>&1; then
    tsx "$VALIDATOR_FILE" "$(cat "$sample_file")"
  elif command -v pnpm >/dev/null 2>&1; then
    pnpm exec tsx "$VALIDATOR_FILE" "$(cat "$sample_file")"
  elif command -v npx >/dev/null 2>&1; then
    npx tsx "$VALIDATOR_FILE" "$(cat "$sample_file")"
  else
    echo "FAIL: tsx runtime not available"
    exit 1
  fi
}

echo "Running valid corpus..."
run_validator "$VALID_SAMPLE"
echo "PASS: valid corpus accepted"

echo
echo "Running invalid corpus..."
set +e
run_validator "$INVALID_SAMPLE"
invalid_exit=$?
set -e

if [ "$invalid_exit" -eq 0 ]; then
  echo "FAIL: invalid corpus unexpectedly passed"
  exit 1
fi

echo "PASS: invalid corpus correctly rejected"
echo
echo "Phase 68 validator smoke passed."
