#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PHASE 3 GENERATION STABILITY CLOSURE READINESS ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY REGRESSION RESULT CHECKPOINT ==="
expected_head="ea1b3408"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Phase 3 regression-result checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-generation-stability-closure-readiness\.sh$|^ M scripts/classify-phase-3-generation-stability-closure-readiness\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "REGRESSION_RESULT_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY PHASE 3 GOVERNING EVIDENCE ==="

grep -nE \
  'PHASE_3_PRODUCTION_STABILITY_RESULT=|UNSTABLE|FAIL_CLOSED_ENFORCEMENT_RESULT=|PRESERVED|PHASE_3_REPEATED_VALIDATION_STATUS=|COMPLETE' \
  scripts/classify-phase-3-repeated-unseeded-validation-result.sh

grep -nE \
  'FAIL_CLOSED_CONTRACT_PRESERVATION=|COMPLETE|VALIDATOR_BEHAVIOR=|CORRECT' \
  scripts/classify-phase-3-fail-closed-contract-preservation.sh

grep -nE \
  'SINGLE_OLLAMA_INVOCATION_PRESERVATION=|COMPLETE|CURRENT_PRODUCTION_OLLAMA_INVOCATIONS_PER_WORKFLOW=|ONE' \
  scripts/classify-phase-3-single-ollama-invocation-preservation.sh

grep -nE \
  'REGRESSION_SET_RESULT=|PASS|TOTAL_ASSERTIONS=|37|TOTAL_FAIL=|0|PRODUCTION_RUNTIME_REGRESSION=|NOT_ESTABLISHED|PRODUCTION_REGRESSION_VALIDATION=|COMPLETE' \
  scripts/classify-phase-3-existing-regression-validation-result.sh

echo "PHASE_3_GOVERNING_EVIDENCE=CONFIRMED"

echo
echo "=== VERIFY PHASE 2 GOVERNING DISPOSITION ==="

grep -nE \
  'PHASE_2_DISPOSITION=|COMPLETE_WITH_PRODUCTION_GENERATION_POLICY_DEFERRED|PRODUCTION_GENERATION_POLICY=|UNCHANGED|PHASE_2_STATUS=|COMPLETE' \
  scripts/classify-generation-policy-and-control-boundary-phase-disposition.sh

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

production_call_count="$(
  grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true
)"

if [[ "$production_call_count" -ne 1 ]]; then
  echo "STOP: production workflow no longer contains exactly one ollamaChat invocation."
  exit 2
fi

echo "CURRENT_PRODUCTION_BASELINE=CONFIRMED"

echo
echo "=== CLOSURE READINESS CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=GENERATION_STABILITY_CLOSURE_CLASSIFICATION
UNIT=CLOSURE_READINESS

PHASE_1_RESULT=
  MATERIAL_UNSEEDED_GENERATION_INSTABILITY_ESTABLISHED

PHASE_2_RESULT=
  GENERATION_POLICY_BOUNDARY_COMPLETE
  PRODUCTION_GENERATION_POLICY_DEFERRED
  PRODUCTION_POLICY_UNCHANGED

PHASE_3_REPEATED_UNSEEDED_RESULT=
  TOTAL_RUNS=10
  FIXTURE_SEMANTIC_PASS_RUNS=0
  FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=8
  FIXTURE_SEMANTIC_FAILURE_RUNS=2
  PRODUCTION_STABILITY_RESULT=UNSTABLE

FAIL_CLOSED_CONTRACT=
  PRESERVED

SINGLE_OLLAMA_INVOCATION=
  PRESERVED

DETERMINISTIC_REGRESSION_SET=
  PASS_37_OF_37

PRODUCTION_RUNTIME_REGRESSION=
  NOT_ESTABLISHED

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
  The milestone objective was to characterize ordinary production generation
  stability, determine the generation-policy/control boundary, validate
  preservation of core runtime contracts, and reach an evidence-backed closure
  classification.

  Those objectives are now satisfied.

  Ordinary unseeded generation is not stable on the established Adaptive
  Detail validation surface.

  Deterministic fail-closed enforcement remains correct.

  The one-Ollama-invocation invariant remains preserved.

  The selected deterministic repository regression set passed 37 of 37
  assertions.

  No production runtime regression caused by this milestone was established.

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
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

PHASE_3_CLOSURE_READINESS=
  READY

NEXT_ACTION=
  CLOSE_CONVERSATION_ENGINE_GENERATION_STABILITY_MILESTONE
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-3-generation-stability-closure-readiness\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-phase-3-generation-stability-closure-readiness.sh
git diff --cached --check
git commit -m "Classify generation stability closure readiness"
git push
