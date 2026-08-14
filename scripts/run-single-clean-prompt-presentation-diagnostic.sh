#!/usr/bin/env bash
set -euo pipefail

echo "=== RUN SINGLE CLEAN PROMPT PRESENTATION DIAGNOSTIC ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 29bd936a HEAD
test -z "$(git status --porcelain)"

runner="scripts/run-bounded-prompt-presentation-diagnostic.ts"
test -f "$runner"

active="$(ps aux | grep 'run-bounded-prompt-presentation-diagnostic.ts' | grep -v grep || true)"
if [[ -n "$active" ]]; then
  echo "STOP: diagnostic runner already active."
  printf '%s\n' "$active"
  exit 2
fi

output="artifacts/prompt-presentation-diagnostic-single-$(date +%Y%m%d_%H%M%S).log"
mkdir -p artifacts

echo "SINGLE_RUN_BOUNDARY=CONFIRMED"
echo "OUTPUT=$output"
echo "=== EXECUTE DIAGNOSTIC ==="

npx tsx "$runner" | tee "$output"

echo "=== VERIFY COMPLETE RESULT ==="
grep -q '^DIAGNOSTIC_CLASS=VALIDATION_ONLY_NON_PRODUCTION_AB_COMPARISON$' "$output"
grep -q '^FIXED_SEED=424242$' "$output"
grep -q '^PAIR_COUNT=10$' "$output"
grep -q '^TOTAL_RUNS=20$' "$output"
grep -q '^CONTROL_RUNS=10$' "$output"
grep -q '^EXPERIMENTAL_RUNS=10$' "$output"
grep -q '^PRODUCTION_PROMPT_CHANGE=NONE$' "$output"
grep -q '^PRODUCTION_GENERATION_POLICY_CHANGE=NONE$' "$output"
grep -q '^VALIDATOR_CHANGE=NONE$' "$output"
grep -q '^MODEL_CHANGE=NONE$' "$output"
grep -q '^RETRY_OR_SECOND_MODEL_CALL=NONE$' "$output"
grep -q '^PRODUCTION_CHANGE=NONE$' "$output"

echo "DIAGNOSTIC_EXECUTION=COMPLETE"
echo "RESULT_CAPTURE=$output"
echo "NEXT_ACTION=CLASSIFY_PROMPT_PRESENTATION_DIAGNOSTIC_RESULTS"

git add "$output"
git commit -m "Capture single bounded prompt presentation diagnostic"
git push origin feature/support-source-references-runtime
