#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SOURCE="scripts/run-dashboard-generation-control-comparison.ts"
TMP="/tmp/run-dashboard-generation-control-comparison-controlled-only.ts"
RESULT="docs/checkpoints/MATILDA_UI_503_REPLACEMENT_CONTROLLED_COMPARISON_RESULT.txt"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=dbb2eb80' \
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

if [[ ! -f "$SOURCE" ]]; then
  echo "SOURCE_RUNNER_MISSING=$SOURCE"
  exit 1
fi

grep -q 'validationGenerationSeed' "$SOURCE" || {
  echo 'VALIDATION_SEED_SEAM_NOT_FOUND'
  exit 1
}

grep -q 'const UNSEEDED_RUNS = 10;' "$SOURCE" || {
  echo 'EXPECTED_UNSEEDED_RUN_COUNT_DECLARATION_NOT_FOUND'
  exit 1
}

grep -q 'const CONTROLLED_RUNS = 10;' "$SOURCE" || {
  echo 'EXPECTED_CONTROLLED_RUN_COUNT_DECLARATION_NOT_FOUND'
  exit 1
}

grep -q 'const CONTROLLED_SEED = 424242;' "$SOURCE" || {
  echo 'EXPECTED_CONTROLLED_SEED_NOT_FOUND'
  exit 1
}

python3 - << 'PY'
from pathlib import Path

source = Path("scripts/run-dashboard-generation-control-comparison.ts").read_text()

old = "const UNSEEDED_RUNS = 10;"
new = "const UNSEEDED_RUNS = 0;"

if old not in source:
    raise SystemExit("UNSEEDED_RUN_DECLARATION_NOT_FOUND")

controlled = source.replace(old, new, 1)

Path("/tmp/run-dashboard-generation-control-comparison-controlled-only.ts").write_text(
    controlled
)
PY

printf '\n=== VERIFY CONTROLLED-ONLY TEMP RUNNER ===\n'
grep -nE \
  'UNSEEDED_RUNS|CONTROLLED_RUNS|CONTROLLED_SEED|validationGenerationSeed' \
  "$TMP"

mkdir -p docs/checkpoints

printf '\n=== RUN REPLACEMENT CONTROLLED COMPARISON ===\n'
set +e
npx tsx "$TMP" 2>&1 | tee "$RESULT"
RUN_STATUS=${PIPESTATUS[0]}
set -e

echo "RUN_STATUS=$RUN_STATUS"

printf '\n=== RESULT MARKERS ===\n'
grep -nE \
  'CONTROLLED RUN|COMPARISON SUMMARY|ACCEPTANCE BOUNDARY|PRIMARY_CONTROL_CRITERION|COMPARATIVE_CRITERION|failureClass|accepted|ISSUE_RESOLVED' \
  "$RESULT" || true

printf '\n=== COMPLETION GATE ===\n'
CONTROLLED_COUNT="$(
  grep -c '^=== CONTROLLED RUN [0-9][0-9]*/10 ===$' "$RESULT" || true
)"

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
    'NEXT_ACTION=CLASSIFY_EXACT_INCOMPLETE_OR_FAILED_RUN_WITHOUT_STARTING_ANOTHER_EXPERIMENT'
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

printf '\n=== WORKTREE ===\n'
git status --short
