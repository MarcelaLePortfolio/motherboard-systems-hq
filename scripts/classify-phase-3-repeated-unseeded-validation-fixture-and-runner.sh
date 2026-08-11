#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PHASE 3 REPEATED UNSEEDED VALIDATION FIXTURE AND RUNNER ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY PHASE 3 VALIDATION CONTRACT CHECKPOINT ==="
expected_head="dd135427"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Phase 3 validation-contract checkpoint $expected_head."
  exit 2
fi

echo "PHASE_3_VALIDATION_CONTRACT_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY VALIDATION CONTRACT ==="
grep -nE \
  'PRIMARY_VALIDATION_SURFACE=|EXISTING_ADAPTIVE_DETAIL_MIXED_CONTENT_LIVE_FIXTURE|REPEATED_SAMPLE_REQUIRED=|UNSEEDED_ONLY|10_SEQUENTIAL_IDENTICAL_INVOCATIONS|NO_RETRY_OF_FAILED_RUN|CLASSIFY_PHASE_3_REPEATED_UNSEEDED_VALIDATION_FIXTURE_AND_RUNNER' \
  scripts/define-phase-3-production-stability-validation-contract.sh

echo "PHASE_3_VALIDATION_CONTRACT=CONFIRMED"

fixture="scripts/validate-adaptive-detail-mixed-content-live.ts"

echo
echo "=== VERIFY PRIMARY FIXTURE ==="

if [[ ! -f "$fixture" ]]; then
  echo "STOP: primary Phase 3 fixture is missing: $fixture"
  exit 2
fi

if grep -q 'validationGenerationSeed' "$fixture"; then
  echo "STOP: Phase 3 primary fixture unexpectedly contains validationGenerationSeed."
  exit 2
fi

echo "PRIMARY_FIXTURE_UNSEEDED=CONFIRMED"

echo
echo "=== VERIFY PHASE 1 RUNNER REFERENCE ==="

if [[ ! -f scripts/run-bounded-unseeded-variance-observation.sh ]]; then
  echo "STOP: Phase 1 unseeded observation runner is unavailable."
  exit 2
fi

echo "PHASE_1_RUNNER_REFERENCE=CONFIRMED"

echo
echo "=== VERIFY PRODUCTION WORKFLOW REMAINS UNSEEDED ==="

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_EXPLICIT_GENERATION_CONTROL=ABSENT"

echo
echo "=== FIXTURE AND RUNNER CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=REPEATED_UNSEEDED_BEHAVIORAL_VALIDATION
UNIT=FIXTURE_AND_RUNNER_CLASSIFICATION

PRIMARY_FIXTURE=
  scripts/validate-adaptive-detail-mixed-content-live.ts

FIXTURE_STATUS=
  EXISTING
  UNSEEDED
  PRODUCTION_RELEVANT
  ESTABLISHED_ACCEPTANCE_SURFACE

FIXTURE_CHANGE_REQUIRED=
  NO

RUNNER_REQUIREMENT=
  NEW_PHASE_3_OBSERVATION_RUNNER

RUNNER_PURPOSE=
  Execute the existing Adaptive Detail live fixture exactly ten times under
  unchanged ordinary unseeded generation behavior and preserve one artifact
  pair per invocation.

RUN_COUNT=
  10

RUN_ORDER=
  SEQUENTIAL

RETRY_POLICY=
  NONE

GENERATION_POLICY=
  UNCHANGED

VALIDATION_SEED=
  ABSENT

TEMPERATURE=
  UNCHANGED

TOP_P=
  UNCHANGED

TOP_K=
  UNCHANGED

MODEL=
  UNCHANGED

PROMPT=
  UNCHANGED

VALIDATORS=
  UNCHANGED

OLLAMA_INVOCATIONS=
  ONE_PER_FIXTURE_RUN

PER_RUN_ARTIFACTS=
  stdout
  stderr
  exit_code
  classification
  fingerprint

PER_RUN_CLASSIFICATIONS=
  FIXTURE_SEMANTIC_PASS
  FAIL_CLOSED_OR_RUNTIME_REJECTION
  FIXTURE_SEMANTIC_FAILURE

SUMMARY_OUTPUT=
  TOTAL_RUNS
  FIXTURE_SEMANTIC_PASS_RUNS
  FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS
  FIXTURE_SEMANTIC_FAILURE_RUNS
  UNIQUE_EXACT_OUTPUT_FINGERPRINTS
  OBSERVED_FAILURE_SIGNATURES
  ARTIFACT_DIRECTORY

FAIL_CLOSED_RULE=
  Any adapter rejection caused by invalid model-authored selected-context or
  support-provenance identity is classified as production generation
  instability with correct fail-closed enforcement.

STABLE_ACCEPTANCE_RULE=
  10_OF_10_FIXTURE_SEMANTIC_PASS
  0_FAIL_CLOSED_OR_RUNTIME_REJECTION
  0_FIXTURE_SEMANTIC_FAILURE

PHASE_1_COMPARISON=
  REQUIRED_AFTER_SAMPLE

  Preserve the Phase 3 sample independently.

  Do not overwrite or reinterpret the Phase 1 artifacts.

  Compare counts and failure signatures only after the Phase 3 sample is
  complete.

RUNNER_MUST_NOT=
  - supply validationGenerationSeed;
  - change fixture inputs;
  - change prompts;
  - change validators;
  - introduce retries;
  - introduce generation controls;
  - terminate early after an individual failed run;
  - classify the milestone before all ten bounded runs complete.

IMPLEMENTATION_SCOPE=
  ONE_OBSERVATION_RUNNER_ONLY

AUTHORIZED_TARGET=
  scripts/run-phase-3-repeated-unseeded-production-stability-validation.sh

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

FIXTURE_AND_RUNNER_CLASSIFICATION=
  COMPLETE

NEXT_ACTION=
  IMPLEMENT_PHASE_3_REPEATED_UNSEEDED_PRODUCTION_STABILITY_RUNNER
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-3-repeated-unseeded-validation-fixture-and-runner\.sh$' ||
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
