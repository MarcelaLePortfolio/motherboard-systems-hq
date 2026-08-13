#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 CORRIDOR 5 — PRODUCTION REGRESSION VALIDATION START ==="

boundary="scripts/classify-phase-3-production-regression-validation-boundary.sh"
validation_set="scripts/classify-phase-3-existing-regression-validation-set.sh"
validation_result="scripts/classify-phase-3-existing-regression-validation-result.sh"

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 0468b07b HEAD

echo "DR_CHECKPOINT=20260813_105722"
echo "DR_PROTECTS_CORRIDOR_4=YES"
echo "CORRIDOR_4=SINGLE_OLLAMA_INVOCATION"
echo "CORRIDOR_4_STATUS=COMPLETE"
echo "CORRIDOR_5=PRODUCTION_REGRESSION_VALIDATION"
echo "CORRIDOR_5_STATUS=STARTING_INVESTIGATION"

echo
echo "=== VERIFY EXISTING CORRIDOR 5 ARTIFACTS ==="

for artifact in "$boundary" "$validation_set" "$validation_result"; do
  test -f "$artifact"
  echo "PRESENT=$artifact"
done

echo
echo "=== INSPECT EXISTING ARTIFACT ASSUMPTIONS ==="

for artifact in "$boundary" "$validation_set" "$validation_result"; do
  echo "--- $artifact ---"
  grep -nEi \
    'expected_head|ancestor|regression|validation|test|build|ollama|invocation|fail.closed|production|seed|temperature|top_p|top_k|next' \
    "$artifact" || true
done

echo
echo "=== VERIFY CURRENT PREDECESSOR ==="

current_single="scripts/classify-current-phase-3-single-ollama-invocation-preservation.sh"
test -f "$current_single"
grep -q 'SINGLE_OLLAMA_INVOCATION_PRESERVATION=' "$current_single"
grep -q 'COMPLETE' "$current_single"

echo "SINGLE_OLLAMA_INVOCATION_PREDECESSOR=COMPLETE"

echo
echo "=== VERIFY CURRENT PRODUCTION BASELINE ==="

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

production_call_count="$(grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true)"
test "$production_call_count" -eq 1

echo "PRODUCTION_GENERATION_POLICY=UNCHANGED_UNCONFIGURED_UNSEEDED"
echo "PRODUCTION_OLLAMA_INVOCATION_COUNT=ONE"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CORRIDOR 5 RECONCILIATION BOUNDARY ==="
echo "CORRIDOR_5_ACTIVITY=RECONCILE_EXISTING_REGRESSION_VALIDATION_ARTIFACTS_WITH_CURRENT_ANCESTRY"
echo "EXISTING_RESULTS_MUST_NOT_BE_ASSUMED_CURRENT=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_EXISTING_REGRESSION_VALIDATION_SET_CURRENTNESS"
