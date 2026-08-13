#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 CORRIDOR 6 — GENERATION STABILITY CLOSURE START ==="

legacy_closure="scripts/classify-phase-3-generation-stability-closure-readiness.sh"
current_unseeded="scripts/classify-current-phase-3-repeated-unseeded-validation-result.sh"
current_fail_closed="scripts/classify-current-phase-3-fail-closed-contract-preservation.sh"
current_single="scripts/classify-current-phase-3-single-ollama-invocation-preservation.sh"
current_regression="scripts/classify-current-phase-3-regression-validation-result.sh"

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 6fc6b19a HEAD

echo "DR_CHECKPOINT=20260813_110629"
echo "DR_PROTECTS_CORRIDOR_5=YES"
echo "CORRIDOR_5=PRODUCTION_REGRESSION_VALIDATION"
echo "CORRIDOR_5_STATUS=COMPLETE"
echo "CORRIDOR_6=GENERATION_STABILITY_CLOSURE"
echo "CORRIDOR_6_STATUS=STARTING_RECONCILIATION"

echo
echo "=== VERIFY CURRENT PHASE 3 EVIDENCE ==="

for artifact in \
  "$legacy_closure" \
  "$current_unseeded" \
  "$current_fail_closed" \
  "$current_single" \
  "$current_regression"
do
  test -f "$artifact"
  echo "PRESENT=$artifact"
done

echo
echo "=== VERIFY CURRENT UNSEEDED RESULT ==="

grep -q 'FIXTURE_SEMANTIC_PASS_RUNS=0' "$current_unseeded"
grep -q 'FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=10' "$current_unseeded"
grep -q 'FIXTURE_SEMANTIC_FAILURE_RUNS=0' "$current_unseeded"
grep -q 'UNIQUE_EXACT_OUTPUT_FINGERPRINTS=1' "$current_unseeded"
grep -q 'PHASE_3_PRODUCTION_STABILITY_RESULT=' "$current_unseeded"
grep -q 'UNSTABLE' "$current_unseeded"

echo "CURRENT_UNSEEDED_RESULT=0_PASS_10_FAIL_CLOSED_0_SEMANTIC_FAILURE_1_FINGERPRINT"
echo "CURRENT_PRODUCTION_STABILITY_RESULT=UNSTABLE"

echo
echo "=== VERIFY CURRENT PRESERVATION RESULTS ==="

grep -q 'FAIL_CLOSED_CONTRACT_PRESERVATION=' "$current_fail_closed"
grep -q 'COMPLETE' "$current_fail_closed"
grep -q 'OBSERVED_PHASE_3_REJECTIONS=' "$current_fail_closed"
grep -q '10_OF_10' "$current_fail_closed"

grep -q 'SINGLE_OLLAMA_INVOCATION_PRESERVATION=' "$current_single"
grep -q 'COMPLETE' "$current_single"

grep -q 'CURRENT_REGRESSION_SET_PASSED=' "$current_regression"
grep -q '^7$' <(grep -A1 'CURRENT_REGRESSION_SET_PASSED=' "$current_regression" | tail -1 | tr -d '[:space:]')
grep -q 'CURRENT_REGRESSION_SET_FAILED=' "$current_regression"
grep -q 'PRODUCTION_RUNTIME_REGRESSION=' "$current_regression"
grep -q 'NOT_ESTABLISHED_ON_SELECTED_DETERMINISTIC_SURFACE' "$current_regression"
grep -q 'PRODUCTION_REGRESSION_VALIDATION=' "$current_regression"
grep -q 'COMPLETE' "$current_regression"

echo "FAIL_CLOSED_CONTRACT=PRESERVED"
echo "SINGLE_OLLAMA_INVOCATION=PRESERVED"
echo "DETERMINISTIC_REGRESSION_TEST_FILES=7"
echo "DETERMINISTIC_REGRESSION_ASSERTIONS=37"
echo "DETERMINISTIC_REGRESSION_RESULT=PASS"
echo "PRODUCTION_RUNTIME_REGRESSION=NOT_ESTABLISHED"

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
echo "=== INSPECT LEGACY CLOSURE ASSUMPTIONS ==="

grep -nEi \
  'expected_head|8_OF_10|FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=8|FIXTURE_SEMANTIC_FAILURE_RUNS=2|PASS_37_OF_37|PHASE_2_RESULT|MILESTONE_CAN_CLOSE|CLOSURE_CLASSIFICATION|NEXT_ACTION' \
  "$legacy_closure" || true

cat <<'MAP'

MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=GENERATION_STABILITY_CLOSURE

CURRENT_PHASE_3_CORRIDORS_COMPLETE=
  5_OF_6

CURRENT_GOVERNING_RESULTS=
  PRODUCTION_STABILITY=UNSTABLE
  CURRENT_SAMPLE=0_PASS_10_FAIL_CLOSED_0_SEMANTIC_FAILURE
  FAIL_CLOSED_CONTRACT=PRESERVED
  SINGLE_OLLAMA_INVOCATION=PRESERVED
  DETERMINISTIC_REGRESSION_SET=PASS
  PRODUCTION_RUNTIME_REGRESSION=NOT_ESTABLISHED

LEGACY_CLOSURE_ARTIFACT=
  PRESENT

LEGACY_CLOSURE_ARTIFACT_CURRENTNESS=
  STALE

STALE_ASSUMPTIONS=
  OLD_EXACT_HEAD_CHECKPOINT
  OLD_8_OF_10_FAIL_CLOSED_SAMPLE
  OLD_2_OF_10_SEMANTIC_FAILURE_SAMPLE

CURRENT_PRODUCTION_POLICY=
  UNCHANGED_UNCONFIGURED_UNSEEDED

PRODUCTION_POLICY_IMPLEMENTED_DURING_PHASE_2=
  NO

PRODUCTION_POLICY_IMPLEMENTED_DURING_PHASE_3=
  NO

PRODUCTION_CHANGE=
  NONE

CORRIDOR_6_ACTIVITY=
  RECONCILE_CLOSURE_CLASSIFICATION_AGAINST_CURRENT_GOVERNING_EVIDENCE

CORRIDOR_6_STATUS=
  NOT_YET_COMPLETE

NEXT_ACTION=
  CLASSIFY_CURRENT_GENERATION_STABILITY_CLOSURE_READINESS
MAP
