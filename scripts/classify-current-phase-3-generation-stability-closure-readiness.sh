#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY CURRENT PHASE 3 GENERATION STABILITY CLOSURE READINESS ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor b621bcc2 HEAD

current_unseeded="scripts/classify-current-phase-3-repeated-unseeded-validation-result.sh"
current_fail_closed="scripts/classify-current-phase-3-fail-closed-contract-preservation.sh"
current_single="scripts/classify-current-phase-3-single-ollama-invocation-preservation.sh"
current_regression="scripts/classify-current-phase-3-regression-validation-result.sh"
phase2="scripts/classify-generation-policy-and-control-boundary-phase-disposition.sh"

for artifact in \
  "$current_unseeded" \
  "$current_fail_closed" \
  "$current_single" \
  "$current_regression" \
  "$phase2"
do
  test -f "$artifact"
done

echo "=== VERIFY CURRENT PHASE 3 GOVERNING EVIDENCE ==="

grep -q 'FIXTURE_SEMANTIC_PASS_RUNS=0' "$current_unseeded"
grep -q 'FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=10' "$current_unseeded"
grep -q 'FIXTURE_SEMANTIC_FAILURE_RUNS=0' "$current_unseeded"
grep -q 'UNIQUE_EXACT_OUTPUT_FINGERPRINTS=1' "$current_unseeded"
grep -q 'UNSTABLE' "$current_unseeded"

grep -q 'OBSERVED_PHASE_3_REJECTIONS=' "$current_fail_closed"
grep -q '10_OF_10' "$current_fail_closed"
grep -q 'FAIL_CLOSED_CONTRACT_PRESERVATION=' "$current_fail_closed"
grep -q 'COMPLETE' "$current_fail_closed"

grep -q 'SINGLE_OLLAMA_INVOCATION_PRESERVATION=' "$current_single"
grep -q 'COMPLETE' "$current_single"

grep -q 'CURRENT_REGRESSION_SET_EXECUTED=' "$current_regression"
grep -q 'CURRENT_REGRESSION_SET_PASSED=' "$current_regression"
grep -q 'CURRENT_REGRESSION_SET_FAILED=' "$current_regression"
grep -q 'REGRESSION_SET_RESULT=' "$current_regression"
grep -q 'PASS' "$current_regression"
grep -q 'PRODUCTION_RUNTIME_REGRESSION=' "$current_regression"
grep -q 'NOT_ESTABLISHED_ON_SELECTED_DETERMINISTIC_SURFACE' "$current_regression"
grep -q 'PRODUCTION_REGRESSION_VALIDATION=' "$current_regression"
grep -q 'COMPLETE' "$current_regression"

echo "PHASE_3_GOVERNING_EVIDENCE=CONFIRMED"

echo
echo "=== VERIFY PHASE 2 GOVERNING DISPOSITION ==="

grep -q 'PHASE_2_DISPOSITION=' "$phase2"
grep -q 'COMPLETE_WITH_PRODUCTION_GENERATION_POLICY_DEFERRED' "$phase2"
grep -q 'PRODUCTION_GENERATION_POLICY=' "$phase2"
grep -q 'UNCHANGED' "$phase2"
grep -q 'PHASE_2_STATUS=' "$phase2"
grep -q 'COMPLETE' "$phase2"

echo "PHASE_2_DISPOSITION=CONFIRMED"

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

echo "CURRENT_PRODUCTION_BASELINE=CONFIRMED"

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

PHASE=
PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE

CORRIDOR=
GENERATION_STABILITY_CLOSURE

PHASE_1_RESULT=
MATERIAL_UNSEEDED_GENERATION_INSTABILITY_ESTABLISHED

PHASE_2_RESULT=
GENERATION_POLICY_BOUNDARY_COMPLETE
PRODUCTION_GENERATION_POLICY_DEFERRED
PRODUCTION_POLICY_UNCHANGED

PHASE_3_CURRENT_UNSEEDED_RESULT=
TOTAL_RUNS=10
FIXTURE_SEMANTIC_PASS_RUNS=0
FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=10
FIXTURE_SEMANTIC_FAILURE_RUNS=0
UNIQUE_EXACT_OUTPUT_FINGERPRINTS=1
PRODUCTION_STABILITY_RESULT=UNSTABLE

FAIL_CLOSED_CONTRACT=
PRESERVED

SINGLE_OLLAMA_INVOCATION=
PRESERVED

DETERMINISTIC_REGRESSION_SET=
7_OF_7_TEST_FILES_PASS
37_OF_37_ASSERTIONS_PASS

PRODUCTION_RUNTIME_REGRESSION=
NOT_ESTABLISHED_ON_SELECTED_DETERMINISTIC_SURFACE

CURRENT_PRODUCTION_GENERATION_POLICY=
UNSEEDED
NO_EXPLICIT_TEMPERATURE
NO_EXPLICIT_TOP_P
NO_EXPLICIT_TOP_K
OLLAMA_AND_MODEL_DEFAULTS

MILESTONE_CAN_CLOSE=
YES

CLOSURE_CLASSIFICATION=
COMPLETE_WITH_PRODUCTION_GENERATION_INSTABILITY_EXPLICITLY_ESTABLISHED

RATIONALE=
The milestone has now characterized ordinary production-equivalent generation,
classified the production generation-policy boundary, validated fail-closed
preservation, validated the single-Ollama-invocation invariant, and completed
the selected deterministic regression surface.

The current Phase 3 sample does not establish production generation stability.
Zero of ten unseeded production-equivalent runs satisfied semantic acceptance,
and all ten were rejected by the deterministic invocation-aware fail-closed
validator for invalid model-authored project-context support provenance.

That current sample differs numerically from the earlier Phase 1 sample but
supports the same governing conclusion: material unseeded generation
instability remains established.

Fail-closed behavior is preserved, one Ollama invocation remains preserved,
and the selected deterministic regression surface passes completely.

No repository or production-runtime regression caused by this milestone has
been established on the selected deterministic surface.

Phase 2 deliberately deferred production generation-policy promotion because
wider semantic preservation and production policy authority were not
established.

UNRESOLVED_PRODUCTION_CONDITION=
GENERATION_INSTABILITY_REMAINS

UNRESOLVED_CONDITION_CLASS=
EXPLICIT_DEFERRED_PRODUCTION_POLICY_CONCERN

UNRESOLVED_CONDITION_BLOCKS_MILESTONE_CLOSURE=
NO

UNRESOLVED_CONDITION_BLOCKS_UNQUALIFIED_STABLE_CLAIM=
YES

UNQUALIFIED_PRODUCTION_STABLE=
NO

PRODUCTION_GENERATION_POLICY_PROMOTION=
NOT_AUTHORIZED

FIXED_SEED_PROMOTION=
NOT_AUTHORIZED

VALIDATOR_RELAXATION=
NOT_AUTHORIZED

RETRY_OR_MULTI_INVOCATION=
NOT_AUTHORIZED

MODEL_CHANGE=
NOT_AUTHORIZED

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
NO

PRODUCTION_GENERATION_POLICY=
UNCHANGED_UNCONFIGURED_UNSEEDED

PRODUCTION_CHANGE=
NONE

PHASE_3_CLOSURE_READINESS=
READY

CORRIDOR_6_CLOSURE_READINESS=
ESTABLISHED

NEXT_ACTION=
CLOSE_CONVERSATION_ENGINE_GENERATION_STABILITY_MILESTONE
MAP
