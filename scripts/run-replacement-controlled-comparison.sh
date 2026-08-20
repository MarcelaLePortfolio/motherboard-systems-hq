#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SOURCE="scripts/run-dashboard-generation-control-comparison.ts"
TMP="scripts/.run-dashboard-generation-control-comparison-controlled-only.ts"
RESULT="docs/checkpoints/MATILDA_UI_503_REPLACEMENT_CONTROLLED_COMPARISON_RESULT.txt"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=faee66f1' \
  'AUTHORIZATION=EXPLICIT_USER_AUTHORIZATION_RECEIVED' \
  'MODE=VALIDATION_ONLY_REPLACEMENT_CONTROLLED_COMPARISON' \
  'ISSUE_RESOLVED=NO' \
  'CONTROLLED_RUNS=10' \
  'CONTROLLED_SEED=424242' \
  'UNSEEDED_RUNS=0' \
  'DATABASE_WRITE=NONE' \
  'PRODUCTION_FILE_MUTATION=NONE' \
  'VALIDATOR_CHANGE=NONE' \
  'GENERATION_POLICY_CHANGE=NONE'

python3 - << 'PY'
from pathlib import Path

source_path = Path("scripts/run-dashboard-generation-control-comparison.ts")
temp_path = Path("scripts/.run-dashboard-generation-control-comparison-controlled-only.ts")

source = source_path.read_text()
old = "const UNSEEDED_RUNS = 10;"
new = "const UNSEEDED_RUNS = 0;"

if old not in source:
    raise SystemExit("EXPECTED_UNSEEDED_RUN_COUNT_DECLARATION_NOT_FOUND")

temp_path.write_text(source.replace(old, new, 1))
PY

trap 'rm -f "$TMP"' EXIT

printf '\n=== VERIFY CONTROLLED-ONLY TEMP RUNNER ===\n'
grep -nE \
  'UNSEEDED_RUNS|CONTROLLED_RUNS|CONTROLLED_SEED|validationGenerationSeed' \
  "$TMP"

printf '\n=== RUN REPLACEMENT CONTROLLED COMPARISON ===\n'
set +e
npx tsx "$TMP" 2>&1 | tee "$RESULT"
RUN_STATUS=${PIPESTATUS[0]}
set -e

echo "RUN_STATUS=$RUN_STATUS"

printf '\n=== RESULT MARKERS ===\n'
grep -nE \
  'CONTROLLED RUN|COMPARISON SUMMARY|ACCEPTANCE BOUNDARY|PRIMARY_CONTROL_CRITERION|COMPARATIVE_CRITERION|failureClass|accepted' \
  "$RESULT" || true

CONTROLLED_COUNT="$(grep -c '^=== CONTROLLED RUN [0-9][0-9]*/10 ===$' "$RESULT" || true)"

printf '\n=== COMPLETION GATE ===\n'
echo "CONTROLLED_RESULT_BLOCK_COUNT=$CONTROLLED_COUNT"

if [[ "$RUN_STATUS" -eq 0 ]] \
  && [[ "$CONTROLLED_COUNT" -eq 10 ]] \
  && grep -q '^=== COMPARISON SUMMARY ===$' "$RESULT" \
  && grep -q '^=== ACCEPTANCE BOUNDARY ===$' "$RESULT"; then
  printf '%s\n' \
    'REPLACEMENT_CONTROLLED_COMPARISON_COMPLETE=YES' \
    'CONTROLLED_RUNS_CAPTURED=10_OF_10' \
    'FINAL_COMPARISON_SUMMARY_CAPTURED=YES' \
    'NEXT_ACTION=CLASSIFY_REPLACEMENT_CONTROLLED_COMPARISON_RESULT'
else
  printf '%s\n' \
    'REPLACEMENT_CONTROLLED_COMPARISON_COMPLETE=NO' \
    "CONTROLLED_RUNS_CAPTURED=${CONTROLLED_COUNT}_OF_10" \
    'NEXT_ACTION=CLASSIFY_THIS_FAILED_ATTEMPT_BEFORE_ANY_FURTHER_RETRY'
  exit 1
fi

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'PRODUCTION_SEED_AUTHORIZED=NO' \
  'PRODUCTION_POLICY_CHANGE_AUTHORIZED=NO' \
  'VALIDATOR_CHANGE_AUTHORIZED=NO' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'MODEL_CHANGE_AUTHORIZED=NO' \
  'RETRY_CHANGE_AUTHORIZED=NO' \
  'PERSISTENCE_CHANGE_AUTHORIZED=NO' \
  'ISSUE_RESOLVED=NO'

git status --short
