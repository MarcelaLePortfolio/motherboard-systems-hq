#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

OUTPUT_FILE="$(mktemp)"
trap 'rm -f "$OUTPUT_FILE"' EXIT

set +e
bash scripts/_local/phase73_run_safety_gate.sh >"$OUTPUT_FILE" 2>&1
EXIT_CODE=$?
set -e

echo "PHASE 73 — OPERATOR SAFETY GATE SMOKE"
echo "-------------------------------------"

grep -q '^RUNNING OPERATOR SAFETY GATE$' "$OUTPUT_FILE"
grep -q '^PHASE 73 — OPERATOR SAFETY GATE$' "$OUTPUT_FILE"
grep -q '^risk=' "$OUTPUT_FILE"
grep -q '^safe_to_continue=' "$OUTPUT_FILE"

if [[ "$EXIT_CODE" -eq 0 ]]; then
  grep -q '^SAFETY GATE: PASS$' "$OUTPUT_FILE"
  grep -q '^RESULT: SAFE TO PROCEED$' "$OUTPUT_FILE"
elif [[ "$EXIT_CODE" -eq 1 ]]; then
  grep -q '^SAFETY GATE: CAUTION$' "$OUTPUT_FILE"
  grep -q '^RESULT: CAUTION — INVESTIGATION ADVISED$' "$OUTPUT_FILE"
elif [[ "$EXIT_CODE" -eq 2 ]]; then
  grep -q '^SAFETY GATE: BLOCK$' "$OUTPUT_FILE"
  grep -q '^RESULT: BLOCKED — RESTORE REQUIRED$' "$OUTPUT_FILE"
else
  echo "Unexpected exit code: $EXIT_CODE" >&2
  cat "$OUTPUT_FILE" >&2
  exit 1
fi

echo "PASS: safety gate contract verified"
