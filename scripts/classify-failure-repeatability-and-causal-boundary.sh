#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY FAILURE REPEATABILITY AND CAUSAL BOUNDARY ==="

expected_head="b81527fc"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Failure Characterization checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-failure-repeatability-and-causal-boundary\.sh$|^ M scripts/classify-failure-repeatability-and-causal-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== VERIFY OBSERVED FAILURE CLASSIFICATION ==="

grep -q 'TWO_OBSERVED_FAILURE_CLASSES_ESTABLISHED' \
  scripts/classify-failure-characterization-observed-classes.sh

grep -q 'FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=8' \
  scripts/classify-phase-3-repeated-unseeded-validation-result.sh

grep -q 'FIXTURE_SEMANTIC_FAILURE_RUNS=2' \
  scripts/classify-phase-3-repeated-unseeded-validation-result.sh

grep -q 'UNIQUE_EXACT_OUTPUT_FINGERPRINTS=3' \
  scripts/classify-phase-3-repeated-unseeded-validation-result.sh

echo "UNSEEDED_FAILURE_EVIDENCE=CONFIRMED"

echo
echo "=== VERIFY FIXED-SEED DIAGNOSTIC EVIDENCE ==="

grep -q 'FIXED_SEED=424242' \
  scripts/classify-bounded-fixed-seed-diagnostic-result.sh

grep -q 'EXACT_REPEATABILITY_OBSERVED=YES' \
  scripts/classify-bounded-fixed-seed-diagnostic-result.sh

grep -q 'PRODUCTION_WORKFLOW_VALIDATION_SEED=ABSENT' \
  scripts/classify-bounded-fixed-seed-diagnostic-result.sh

echo "FIXED_SEED_DIAGNOSTIC_EVIDENCE=CONFIRMED"

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION

CORRIDOR_MAP=
USER_GOVERNED_AND_FIXED

CORRIDOR=
FAILURE_CHARACTERIZATION

GENERATION_VARIANCE=
COMPLETE

FAILURE_CHARACTERIZATION=
ACTIVE

UNSEEDED_REPEATABILITY_RESULT=
FAILURE_PATTERN_REPEATED_BUT_EXACT_OUTPUT_NOT_STABLE

UNSEEDED_SAMPLE=
TOTAL_RUNS=10
FULL_SEMANTIC_SUCCESS=0_OF_10
FAIL_CLOSED_OR_RUNTIME_REJECTION=8_OF_10
SEMANTIC_ACCEPTANCE_FAILURE=2_OF_10
UNIQUE_EXACT_OUTPUT_FINGERPRINTS=3

FIXED_SEED_DIAGNOSTIC_RESULT=
EXACT_REPEATABILITY_OBSERVED

FIXED_SEED=
424242

FIXED_SEED_SCOPE=
VALIDATION_ONLY

PRODUCTION_WORKFLOW_SEED=
ABSENT

REPEATABILITY_CLASSIFICATION=
ORDINARY_UNSEEDED_GENERATION_EXHIBITS_OUTPUT_VARIANCE_WHILE_FIXED_SEED_DIAGNOSTIC_GENERATION_CAN_REPEAT_EXACTLY

CAUSAL_BOUNDARY_CLASSIFICATION=
GENERATION_LAYER_SENSITIVITY_ESTABLISHED
DETERMINISTIC_RUNTIME_REGRESSION_NOT_ESTABLISHED
VALIDATOR_MALFUNCTION_NOT_ESTABLISHED

CAUSAL_INTERPRETATION=
The ordinary production-equivalent unseeded sample repeatedly failed the
established semantic acceptance surface while producing multiple exact output
fingerprints.

The bounded fixed-seed diagnostic demonstrated exact repeatability under a
controlled validation-only generation condition.

Together, those observations establish that generation behavior is sensitive
to the model-generation control state and that the observed failures occur
upstream of deterministic acceptance and fail-closed enforcement.

They do not establish that seed alone is the root cause of every semantic
failure, that a fixed seed is an acceptable production policy, or that any
production generation-policy change is authorized.

FAIL_CLOSED_VALIDATOR=
PRESERVED

ONE_OLLAMA_INVOCATION=
PRESERVED

PRODUCTION_RUNTIME_REGRESSION=
NOT_ESTABLISHED

FIXED_SEED_AS_ROOT_CAUSE=
NOT_ESTABLISHED

FIXED_SEED_AS_PRODUCTION_REMEDY=
NOT_ESTABLISHED

PRODUCTION_GENERATION_POLICY_CHANGE=
NOT_AUTHORIZED

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

CORRIDOR_CLOSURE=
NO

FAILURE_CHARACTERIZATION_CORRIDOR=
ACTIVE

NEXT_ACTION=
DETERMINE_FAILURE_CHARACTERIZATION_COMPLETENESS
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-failure-repeatability-and-causal-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Failure Characterization scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo
echo "=== DIFF CHECK ==="
git diff --check
