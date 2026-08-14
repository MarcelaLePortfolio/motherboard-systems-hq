#!/usr/bin/env bash
set -euo pipefail

echo "=== RUN SINGLE BOUNDED UNSEEDED PRESENTATION VALIDATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor f4cd3dac HEAD
test -z "$(git status --porcelain)"

runner="scripts/run-bounded-unseeded-experimental-presentation-validation.ts"
test -f "$runner"

active="$(ps aux | grep 'run-bounded-unseeded-experimental-presentation-validation.ts' | grep -v grep || true)"
if [[ -n "$active" ]]; then
  echo "STOP: unseeded validation runner already active."
  printf '%s\n' "$active"
  exit 2
fi

output="artifacts/unseeded-experimental-presentation-validation-$(date +%Y%m%d_%H%M%S).log"
mkdir -p artifacts

echo "SINGLE_RUN_BOUNDARY=CONFIRMED"
echo "OUTPUT=$output"
echo "=== EXECUTE 10 SEQUENTIAL UNSEEDED RUNS ==="

npx tsx "$runner" | tee "$output"

echo "=== VERIFY COMPLETE RESULT ==="
grep -q '^VALIDATION_CLASS=NON_PRODUCTION_PRODUCTION_EQUIVALENT_UNSEEDED_PRESENTATION_VALIDATION$' "$output"
grep -q '^TEST_ARM=EXPERIMENTAL_PRESENTATION_ONLY$' "$output"
grep -q '^PRESENTATION_VARIANT=EXPLICIT_PARENT_CHILD_SEPARATION$' "$output"
grep -q '^GENERATION_SEED=ABSENT$' "$output"
grep -q '^RUN_COUNT=10$' "$output"
grep -q '^PRODUCTION_PROMPT_CHANGE=NONE$' "$output"
grep -q '^PRODUCTION_GENERATION_POLICY_CHANGE=NONE$' "$output"
grep -q '^VALIDATOR_CHANGE=NONE$' "$output"
grep -q '^MODEL_CHANGE=NONE$' "$output"
grep -q '^RETRY_OR_SECOND_MODEL_CALL=NONE$' "$output"
grep -q '^PRODUCTION_CHANGE=NONE$' "$output"

echo "VALIDATION_EXECUTION=COMPLETE"
echo "RESULT_CAPTURE=$output"
echo "NEXT_ACTION=CLASSIFY_BOUNDED_UNSEEDED_PRESENTATION_VALIDATION_RESULTS"

git add "$output"
git commit -m "Capture bounded unseeded presentation validation"
git push origin feature/support-source-references-runtime
