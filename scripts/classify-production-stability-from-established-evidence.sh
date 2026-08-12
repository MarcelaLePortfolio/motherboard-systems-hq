#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PRODUCTION STABILITY FROM ESTABLISHED EVIDENCE ==="

expected_head="622412fd"

[[ "$(git rev-parse --short=8 HEAD)" == "$expected_head" ]] || {
  echo "STOP: HEAD no longer matches Stability Determination baseline $expected_head."
  exit 2
}

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-production-stability-from-established-evidence\.sh$|^ M scripts/classify-production-stability-from-established-evidence\.sh$' ||
  true
)"

[[ -z "$unexpected" ]] || {
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
}

echo "=== VERIFY ESTABLISHED EVIDENCE ==="

grep -q 'TOTAL_RUNS=10' scripts/classify-phase-3-repeated-unseeded-validation-result.sh
grep -q 'FIXTURE_SEMANTIC_PASS_RUNS=0' scripts/classify-phase-3-repeated-unseeded-validation-result.sh
grep -q 'FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=8' scripts/classify-phase-3-repeated-unseeded-validation-result.sh
grep -q 'FIXTURE_SEMANTIC_FAILURE_RUNS=2' scripts/classify-phase-3-repeated-unseeded-validation-result.sh
grep -q 'UNIQUE_EXACT_OUTPUT_FINGERPRINTS=3' scripts/classify-phase-3-repeated-unseeded-validation-result.sh

grep -q 'GENERATION_LAYER_SENSITIVITY_ESTABLISHED' \
  scripts/classify-failure-repeatability-and-causal-boundary.sh
grep -q 'DETERMINISTIC_RUNTIME_REGRESSION_NOT_ESTABLISHED' \
  scripts/classify-failure-repeatability-and-causal-boundary.sh
grep -q 'VALIDATOR_MALFUNCTION_NOT_ESTABLISHED' \
  scripts/classify-failure-repeatability-and-causal-boundary.sh

grep -q 'REQUEST_SCOPED_VALIDATION_ONLY_FIXED_SEED' \
  scripts/classify-diagnostic-controls-completeness.sh
grep -q 'CONTROLLED_REPEATABILITY=' \
  scripts/classify-diagnostic-controls-completeness.sh
grep -q 'PRODUCTION_POLICY_SEPARATION=' \
  scripts/classify-diagnostic-controls-completeness.sh

echo "ESTABLISHED_EVIDENCE=CONFIRMED"

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_GENERATION_STABILITY

PHASE=
PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION

CORRIDOR_MAP=
USER_GOVERNED_AND_FIXED

CORRIDOR=
STABILITY_DETERMINATION

GENERATION_VARIANCE=
COMPLETE

FAILURE_CHARACTERIZATION=
COMPLETE

DIAGNOSTIC_CONTROLS=
COMPLETE

STABILITY_DETERMINATION=
ACTIVE

PRODUCTION_EQUIVALENT_SAMPLE=
TOTAL_RUNS=10
FULL_SEMANTIC_PASS_RUNS=0
FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=8
SEMANTIC_ACCEPTANCE_FAILURE_RUNS=2
UNIQUE_EXACT_OUTPUT_FINGERPRINTS=3

ORDINARY_PRODUCTION_GENERATION_REPEATABILITY=
NOT_ESTABLISHED

ORDINARY_PRODUCTION_SEMANTIC_RELIABILITY=
NOT_ESTABLISHED

CONTROLLED_FIXED_SEED_REPEATABILITY=
ESTABLISHED_ON_VALIDATION_ONLY_DIAGNOSTIC_SURFACE

FIXED_SEED_AS_PRODUCTION_POLICY=
NOT_ESTABLISHED

FIXED_SEED_AS_PRODUCTION_REMEDY=
NOT_ESTABLISHED

FAIL_CLOSED_VALIDATION=
PRESERVED

VALIDATOR_MALFUNCTION=
NOT_ESTABLISHED

DETERMINISTIC_RUNTIME_REGRESSION=
NOT_ESTABLISHED

PRODUCTION_STABILITY_DETERMINATION=
UNQUALIFIED_PRODUCTION_STABILITY_NOT_ESTABLISHED

PRODUCTION_INSTABILITY_DETERMINATION=
MATERIAL_GENERATION_INSTABILITY_ESTABLISHED_ON_TESTED_PRODUCTION_EQUIVALENT_SURFACE

STABILITY_INTERPRETATION=
The established production-equivalent unseeded sample produced zero full
semantic passes across ten runs.

Eight runs were correctly rejected by fail-closed validation and two additional
runs failed the established semantic acceptance surface after successful adapter
return.

Multiple exact output fingerprints establish ordinary generation variance.

The validation-only fixed-seed diagnostic established controlled repeatability,
but does not establish fixed seed as an acceptable production policy or remedy.

Therefore unqualified production stability is not established on the tested
surface, while material production-generation instability is established.

This determination does not establish validator malfunction, deterministic
runtime regression, or authorization for a production generation-policy change.

PRODUCTION_GENERATION_POLICY_CHANGE=
NOT_AUTHORIZED

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE

CORRIDOR_CLOSURE=
NO

STABILITY_DETERMINATION_CORRIDOR=
ACTIVE

NEXT_ACTION=
DETERMINE_STABILITY_DETERMINATION_COMPLETENESS
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-production-stability-from-established-evidence\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside Stability Determination scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
