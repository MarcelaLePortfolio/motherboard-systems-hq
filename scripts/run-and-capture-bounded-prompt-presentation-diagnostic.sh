#!/usr/bin/env bash
set -euo pipefail

echo "=== RUN AND CAPTURE BOUNDED PROMPT PRESENTATION DIAGNOSTIC ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 18479dde HEAD
test -z "$(git status --porcelain)"

runner="scripts/run-bounded-prompt-presentation-diagnostic.ts"
output="artifacts/prompt-presentation-diagnostic-$(date +%Y%m%d_%H%M%S).log"

test -f "$runner"
mkdir -p artifacts

echo "=== EXECUTE 10 PAIRED FIXED-SEED CONTROL/EXPERIMENTAL RUNS ==="
npx tsx "$runner" | tee "$output"

echo "=== VERIFY CAPTURE ==="
grep -q '^DIAGNOSTIC_CLASS=VALIDATION_ONLY_NON_PRODUCTION_AB_COMPARISON$' "$output"
grep -q '^FIXED_SEED=424242$' "$output"
grep -q '^PAIR_COUNT=10$' "$output"
grep -q '^TOTAL_RUNS=20$' "$output"
grep -q '^PRODUCTION_PROMPT_CHANGE=NONE$' "$output"
grep -q '^PRODUCTION_GENERATION_POLICY_CHANGE=NONE$' "$output"
grep -q '^VALIDATOR_CHANGE=NONE$' "$output"
grep -q '^MODEL_CHANGE=NONE$' "$output"
grep -q '^RETRY_OR_SECOND_MODEL_CALL=NONE$' "$output"
grep -q '^PRODUCTION_CHANGE=NONE$' "$output"

echo "DIAGNOSTIC_OUTPUT=$output"
echo "DIAGNOSTIC_EXECUTION=COMPLETE"
echo "NEXT_ACTION=CLASSIFY_PROMPT_PRESENTATION_DIAGNOSTIC_RESULTS"

git add "$output"
git commit -m "Capture bounded prompt presentation diagnostic results"
git push origin feature/support-source-references-runtime
