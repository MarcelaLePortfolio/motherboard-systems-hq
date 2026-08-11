#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PHASE 3 PRODUCTION REGRESSION VALIDATION BOUNDARY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY SINGLE-INVOCATION CHECKPOINT ==="
expected_head="1d1825e2"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches single-Ollama preservation checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-production-regression-validation-boundary\.sh$|^ M scripts/classify-phase-3-production-regression-validation-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "SINGLE_OLLAMA_PRESERVATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING PHASE 3 STATE ==="

grep -nE \
  'SINGLE_OLLAMA_INVOCATION_PRESERVATION=|COMPLETE|NEXT_CORRIDOR=|PRODUCTION_REGRESSION_VALIDATION|NEXT_ACTION=|CLASSIFY_PHASE_3_PRODUCTION_REGRESSION_VALIDATION_BOUNDARY' \
  scripts/classify-phase-3-single-ollama-invocation-preservation.sh

echo "GOVERNING_PHASE_3_STATE=CONFIRMED"

echo
echo "=== VERIFY REPEATED VALIDATION RESULT ==="

grep -nE \
  'PHASE_3_PRODUCTION_STABILITY_RESULT=|UNSTABLE|FAIL_CLOSED_ENFORCEMENT_RESULT=|PRESERVED|PRODUCTION_RUNTIME_REGRESSION=|NOT_ESTABLISHED' \
  scripts/classify-phase-3-repeated-unseeded-validation-result.sh

echo "REPEATED_VALIDATION_RESULT=CONFIRMED"

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

echo "PRODUCTION_BASELINE=UNCHANGED"

echo
echo "=== INVENTORY EXISTING REGRESSION SURFACES ==="

find scripts -maxdepth 1 -type f \
  \( \
    -name 'validate-*.ts' -o \
    -name 'test-*.ts' -o \
    -name '*regression*.sh' \
  \) |
  sort

echo
echo "=== REGRESSION VALIDATION BOUNDARY ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=PRODUCTION_REGRESSION_VALIDATION
UNIT=REGRESSION_VALIDATION_BOUNDARY

GOVERNING_PHASE_3_RESULT=
  PRODUCTION_GENERATION_UNSTABLE_ON_ESTABLISHED_ADAPTIVE_DETAIL_SURFACE

FAIL_CLOSED_CONTRACT=
  PRESERVED

SINGLE_OLLAMA_INVOCATION=
  PRESERVED

PRODUCTION_RUNTIME_REGRESSION=
  NOT_ESTABLISHED

REGRESSION_VALIDATION_OBJECTIVE=
  Determine whether the Phase 3 validation work itself introduced any
  repository or runtime regression outside the already-established unstable
  model-generation behavior.

REGRESSION_VALIDATION_MUST_DISTINGUISH=
  1. existing model-generation instability;
  2. deterministic fail-closed behavior;
  3. actual runtime or repository regression caused by milestone changes.

KNOWN_GENERATION_INSTABILITY=
  MUST_NOT_BE_RECLASSIFIED_AS_RUNTIME_REGRESSION

REGRESSION_SCOPE=
  EXISTING_REPOSITORY_SUPPORTED_STATIC_AND_NON_SEMANTIC_REGRESSION_SURFACES

LIVE_UNSEEDED_GENERATION_REPETITION=
  NOT_REQUIRED_FOR_THIS_CORRIDOR

RATIONALE=
  Phase 3 has already completed its bounded repeated unseeded semantic sample.

  Repeating stochastic live generation here would not isolate repository
  regression from the generation instability already established.

  Regression validation should therefore favor deterministic repository
  checks and existing non-semantic/static validation surfaces that can test
  whether milestone work changed runtime contracts.

REGRESSION_VALIDATION_MUST_PRESERVE=
  - one Ollama invocation;
  - fail-closed validators;
  - unseeded production defaults;
  - prompt contract;
  - structured response contract;
  - Investigation Lifecycle contract;
  - durable interpretation separation;
  - selected-context identity validation;
  - support provenance validation.

REGRESSION_VALIDATION_MUST_NOT=
  - introduce a production seed;
  - change temperature, top_p, or top_k;
  - change model;
  - relax validators;
  - add retries;
  - add another Ollama invocation;
  - repair unrelated historical fixtures solely to obtain a passing result;
  - treat known stochastic model failure as repository regression.

IMPLEMENTATION_AUTHORIZED=
  NO

NEW_REGRESSION_FIXTURE_AUTHORIZED=
  NO

FIRST_ACTION=
  CLASSIFY_EXISTING_REPOSITORY_SUPPORTED_PHASE_3_REGRESSION_SET

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

PRODUCTION_REGRESSION_VALIDATION_BOUNDARY=
  ESTABLISHED

NEXT_ACTION=
  CLASSIFY_PHASE_3_EXISTING_REGRESSION_VALIDATION_SET
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-3-production-regression-validation-boundary\.sh$' ||
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
