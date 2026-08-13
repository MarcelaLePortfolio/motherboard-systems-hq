#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PHASE 3 CORRIDOR 2 — UNSEEDED BEHAVIORAL VALIDATION CURRENTNESS ==="

classifier="scripts/classify-phase-3-repeated-unseeded-validation-fixture-and-runner.sh"
runner="scripts/run-phase-3-repeated-unseeded-production-stability-validation.sh"
fixture="scripts/validate-adaptive-detail-mixed-content-live.ts"

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor d8256e8d HEAD

test -f "$classifier"
test -f "$runner"
test -f "$fixture"

echo
echo "=== VERIFY FIXTURE CURRENTNESS ==="

if grep -q 'validationGenerationSeed' "$fixture"; then
  echo "STOP: Phase 3 fixture is seeded."
  exit 2
fi

echo "PRIMARY_FIXTURE_PRESENT=YES"
echo "PRIMARY_FIXTURE_UNSEEDED=YES"

echo
echo "=== VERIFY RUNNER CONTRACT ==="

grep -q 'RUN_COUNT=10' "$runner"
grep -q 'RETRY_POLICY=NONE' "$runner"
grep -q 'for run in $(seq 1 10)' "$runner"
grep -q 'FIXTURE_SEMANTIC_PASS' "$runner"
grep -q 'FAIL_CLOSED_OR_RUNTIME_REJECTION' "$runner"
grep -q 'FIXTURE_SEMANTIC_FAILURE' "$runner"
grep -q 'UNIQUE_EXACT_OUTPUT_FINGERPRINTS' "$runner"
grep -q 'PRODUCTION_GENERATION_POLICY=UNCHANGED' "$runner"
grep -q 'PRODUCTION_CHANGE=NONE' "$runner"

if grep -q 'validationGenerationSeed' "$fixture"; then
  echo "STOP: fixture contains validationGenerationSeed."
  exit 2
fi

if grep -qE 'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

production_call_count="$(grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true)"
test "$production_call_count" -eq 1

echo
echo "=== CURRENTNESS CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=UNSEEDED_BEHAVIORAL_VALIDATION

PRIMARY_FIXTURE=
  scripts/validate-adaptive-detail-mixed-content-live.ts

FIXTURE_CURRENTNESS=
  CURRENT_AND_REUSABLE

RUNNER=
  scripts/run-phase-3-repeated-unseeded-production-stability-validation.sh

RUNNER_CURRENTNESS=
  CURRENT_AND_REUSABLE

SAMPLE_MODE=
  UNSEEDED_ONLY

SAMPLE_SIZE=
  10_SEQUENTIAL_IDENTICAL_INVOCATIONS

RETRY_POLICY=
  NONE

OLLAMA_INVOCATIONS=
  ONE_PER_RUN

FAILURE_CLASSIFICATION=
  FIXTURE_SEMANTIC_PASS
  FAIL_CLOSED_OR_RUNTIME_REJECTION
  FIXTURE_SEMANTIC_FAILURE

PRODUCTION_GENERATION_POLICY=
  UNCHANGED_UNCONFIGURED_UNSEEDED

SEEDED_DIAGNOSTIC_PROMOTION=
  ABSENT

PRODUCTION_CHANGE=
  NONE

IMPLEMENTATION_GAP=
  NONE

CORRIDOR_2_EXECUTION_READINESS=
  ESTABLISHED

NEXT_ACTION=
  RUN_EXISTING_PHASE_3_REPEATED_UNSEEDED_PRODUCTION_STABILITY_VALIDATION
MAP
