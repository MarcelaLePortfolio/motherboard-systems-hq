#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PHASE 3 EXISTING REGRESSION VALIDATION RESULT ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY REGRESSION-SET CHECKPOINT ==="
expected_head="dfd921af"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Phase 3 regression-set checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-3-existing-regression-validation-result\.sh$|^ M scripts/classify-phase-3-existing-regression-validation-result\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "REGRESSION_SET_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CLASSIFIED TEST SET ==="

grep -nE \
  'ADMISSIBLE_REGRESSION_SET=|validate-adaptive-detail-mixed-content-criteria.test.ts|validate-source-excerpt-first-live-contract.test.ts|validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts|validate-investigation-lifecycle-iel-reconstruction.test.ts|validate-investigation-lifecycle-prior-context-transport.test.ts|validate-investigation-lifecycle-scoped-iel-retrieval.test.ts|validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts|SUCCESS_RULE=|ALL_SELECTED_EXISTING_TESTS_PASS' \
  scripts/classify-phase-3-existing-regression-validation-set.sh

echo "CLASSIFIED_TEST_SET=CONFIRMED"

echo
echo "=== RECORD OBSERVED EXECUTION RESULT ==="

cat <<'RESULT'
EXECUTED_TESTS=7

ADAPTIVE_DETAIL_CRITERIA=
  PASS_3_OF_3

SOURCE_EXCERPT_CONTRACT=
  PASS_3_OF_3

INVESTIGATION_LIFECYCLE_JSON_PERSISTENCE=
  PASS_5_OF_5

INVESTIGATION_LIFECYCLE_RECONSTRUCTION=
  PASS_8_OF_8

INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT=
  PASS_6_OF_6

INVESTIGATION_LIFECYCLE_SCOPED_IEL_RETRIEVAL=
  PASS_4_OF_4

INVESTIGATION_LIFECYCLE_TYPED_IEL_WORKFLOW_TRANSPORT=
  PASS_8_OF_8

TOTAL_ASSERTIONS=
  37

TOTAL_PASS=
  37

TOTAL_FAIL=
  0
RESULT

echo
echo "=== VERIFY CURRENT PRODUCTION BASELINE REMAINS UNCHANGED ==="

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
echo "=== REGRESSION RESULT CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=PRODUCTION_REGRESSION_VALIDATION
UNIT=EXISTING_REGRESSION_VALIDATION_RESULT

SELECTED_TEST_FILES=
  7

TOTAL_ASSERTIONS=
  37

TOTAL_PASS=
  37

TOTAL_FAIL=
  0

REGRESSION_SET_RESULT=
  PASS

ADAPTIVE_DETAIL_CRITERIA=
  PRESERVED

SOURCE_EXCERPT_CONTRACT=
  PRESERVED

INVESTIGATION_LIFECYCLE_JSON_PERSISTENCE=
  PRESERVED

INVESTIGATION_LIFECYCLE_RECONSTRUCTION=
  PRESERVED

INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT=
  PRESERVED

INVESTIGATION_LIFECYCLE_SCOPED_IEL_RETRIEVAL=
  PRESERVED

INVESTIGATION_LIFECYCLE_TYPED_IEL_WORKFLOW_TRANSPORT=
  PRESERVED

PRODUCTION_RUNTIME_REGRESSION=
  NOT_ESTABLISHED

CLASSIFICATION=
  All seven selected deterministic repository-supported regression tests
  passed exactly once with no retries.

  The Phase 3 validation work therefore does not establish a repository or
  runtime regression across the selected deterministic regression surface.

  This result does not alter the separately established production-generation
  instability finding.

  The production-generation instability and deterministic repository
  regression classifications remain distinct.

KNOWN_PRODUCTION_GENERATION_INSTABILITY=
  PRESERVED_AS_SEPARATE_FINDING

FAIL_CLOSED_CONTRACT=
  PRESERVED

SINGLE_OLLAMA_INVOCATION=
  PRESERVED

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_CHANGE=
  NONE

PRODUCTION_REGRESSION_VALIDATION=
  COMPLETE

NEXT_CORRIDOR=
  GENERATION_STABILITY_CLOSURE_CLASSIFICATION

NEXT_ACTION=
  CLASSIFY_PHASE_3_GENERATION_STABILITY_CLOSURE_READINESS
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-3-existing-regression-validation-result\.sh$' ||
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

git add scripts/classify-phase-3-existing-regression-validation-result.sh
git diff --cached --check
git commit -m "Classify Phase 3 regression validation result"
git push
