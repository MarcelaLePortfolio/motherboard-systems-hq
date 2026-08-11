#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PHASE 3 EXISTING REGRESSION VALIDATION SET ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY REGRESSION BOUNDARY CHECKPOINT ==="
expected_head="8b7d5561"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches regression-boundary checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-existing-regression-validation-set\.sh$|^ M scripts/classify-phase-3-existing-regression-validation-set\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "REGRESSION_BOUNDARY_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING REGRESSION BOUNDARY ==="

grep -nE \
  'REGRESSION_SCOPE=|EXISTING_REPOSITORY_SUPPORTED_STATIC_AND_NON_SEMANTIC_REGRESSION_SURFACES|LIVE_UNSEEDED_GENERATION_REPETITION=|NOT_REQUIRED_FOR_THIS_CORRIDOR|NEW_REGRESSION_FIXTURE_AUTHORIZED=|NO|CLASSIFY_PHASE_3_EXISTING_REGRESSION_VALIDATION_SET' \
  scripts/classify-phase-3-production-regression-validation-boundary.sh

echo "GOVERNING_REGRESSION_BOUNDARY=CONFIRMED"

echo
echo "=== VERIFY CANDIDATE EXISTING TEST SURFACES ==="

candidates=(
  scripts/validate-adaptive-detail-mixed-content-criteria.test.ts
  scripts/validate-source-excerpt-first-live-contract.test.ts
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts
  scripts/validate-investigation-lifecycle-prior-context-transport.test.ts
  scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts
)

for file in "${candidates[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "STOP: expected regression candidate missing: $file"
    exit 2
  fi
  echo "FOUND=$file"
done

echo "CANDIDATE_EXISTING_TEST_SURFACES=CONFIRMED"

echo
echo "=== VERIFY CANDIDATES ARE NON-LIVE / NON-OLLAMA ==="

for file in "${candidates[@]}"; do
  if grep -qE \
    'ollamaChat\(|/api/generate|validationGenerationSeed|OLLAMA_BASE_URL|OLLAMA_MODEL' \
    "$file"
  then
    echo "STOP: candidate unexpectedly contains live/model-generation surface: $file"
    exit 2
  fi
done

echo "NON_LIVE_REGRESSION_SET=CONFIRMED"

echo
echo "=== REGRESSION SET CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=PRODUCTION_REGRESSION_VALIDATION
UNIT=EXISTING_REGRESSION_VALIDATION_SET_CLASSIFICATION

ADMISSIBLE_REGRESSION_SET=
  scripts/validate-adaptive-detail-mixed-content-criteria.test.ts
  scripts/validate-source-excerpt-first-live-contract.test.ts
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts
  scripts/validate-investigation-lifecycle-prior-context-transport.test.ts
  scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

SET_CHARACTERISTICS=
  EXISTING
  DETERMINISTIC
  NON_LIVE
  NON_SEEDED
  NO_OLLAMA_INVOCATION
  REPOSITORY_SUPPORTED

RESPONSIBILITY_COVERAGE=
  ADAPTIVE_DETAIL_CRITERIA
  SOURCE_EXCERPT_CONTRACT
  INVESTIGATION_LIFECYCLE_JSON_PERSISTENCE
  INVESTIGATION_LIFECYCLE_RECONSTRUCTION
  INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT
  SCOPED_IEL_RETRIEVAL
  TYPED_IEL_WORKFLOW_TRANSPORT

WHY_LIVE_FIXTURES_ARE_EXCLUDED=
  Phase 3 already established ordinary unseeded generation instability on the
  designated semantic surface.

  Additional stochastic live runs would not isolate whether milestone work
  introduced repository regression.

WHY_FIXED_SEED_FIXTURES_ARE_EXCLUDED=
  Fixed-seed evidence remains diagnostic only and production promotion remains
  deferred.

WHY_HISTORICAL_REPAIR_SCRIPTS_ARE_EXCLUDED=
  This corridor must not repair unrelated historical fixtures merely to obtain
  a passing regression result.

EXECUTION_METHOD=
  RUN_EACH_EXISTING_TEST_EXACTLY_ONCE

RUN_ORDER=
  SEQUENTIAL

RETRY_POLICY=
  NONE

FAILURE_RULE=
  Any deterministic test failure must be preserved and classified before any
  attempted repair.

  Do not layer fixes or proceed speculatively.

SUCCESS_RULE=
  ALL_SELECTED_EXISTING_TESTS_PASS

NEW_FIXTURE_REQUIRED=
  NO

FIXTURE_REPAIR_AUTHORIZED=
  NO

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

EXISTING_REGRESSION_VALIDATION_SET=
  CLASSIFIED

NEXT_ACTION=
  RUN_PHASE_3_EXISTING_REGRESSION_VALIDATION_SET
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-3-existing-regression-validation-set\.sh$' ||
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

git add scripts/classify-phase-3-existing-regression-validation-set.sh
git diff --cached --check
git commit -m "Classify Phase 3 existing regression set"
git push
