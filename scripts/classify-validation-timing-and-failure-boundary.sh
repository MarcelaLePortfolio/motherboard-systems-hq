#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY VALIDATION TIMING AND FAILURE BOUNDARY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="f14a3f8c"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches validator-ownership checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-validation-timing-and-failure-boundary\.sh$|^ M scripts/classify-validation-timing-and-failure-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "VALIDATOR_OWNERSHIP_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING OWNERSHIP ==="

grep -q 'CROSS_TURN_TRANSITION_VALIDATION_OWNER=' scripts/classify-transition-validator-ownership.sh
grep -q 'DETERMINISTIC_RUNTIME' scripts/classify-transition-validator-ownership.sh
grep -q 'WORKFLOW_IEL_PERSISTENCE_OWNERSHIP=' scripts/classify-transition-validator-ownership.sh
grep -q 'PRESERVED' scripts/classify-transition-validator-ownership.sh

echo "GOVERNING_OWNERSHIP=CONFIRMED"

echo
echo "=== CLASSIFY VALIDATION TIMING AND FAILURE BOUNDARY ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

MILESTONE_CANDIDATE=
  INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION

PHASE=
  SUCCESSOR_CAPABILITY_READINESS_CLASSIFICATION

CORRIDOR=
  VALIDATION_TIMING_AND_FAILURE_BOUNDARY

VALIDATION_INPUTS=
  ALREADY_SELECTED_PRIOR_INVESTIGATION_LIFECYCLE_OR_NULL
  CURRENT_MODEL_AUTHORED_INVESTIGATION_LIFECYCLE_OR_NULL

VALIDATION_TIMING=
  AFTER_CURRENT_STRUCTURED_RESPONSE_VALIDATION
  AFTER_PRIOR_LIFECYCLE_SELECTION
  BEFORE_CURRENT_LIFECYCLE_DURABLE_PERSISTENCE

VALIDATION_OWNER=
  DETERMINISTIC_RUNTIME

WORKFLOW_ROLE=
  INVOKE_TRANSITION_VALIDATOR_AT_PRE_PERSISTENCE_BOUNDARY

VALID_RELATIONSHIP=
  CONTINUE_EXISTING_WORKFLOW

INVALID_RELATIONSHIP=
  FAIL_CLOSED

INVALID_RELATIONSHIP_PERSISTENCE=
  DO_NOT_PERSIST_INVALID_CURRENT_LIFECYCLE_ARTIFACT

INVALID_RELATIONSHIP_REPAIR=
  NONE

INVALID_RELATIONSHIP_RETRY=
  NONE

SECOND_MODEL_INVOCATION=
  NOT_ALLOWED

SYNTHETIC_TRANSITION_CORRECTION=
  NOT_ALLOWED

LIFECYCLE_FACT_REWRITE=
  NOT_ALLOWED

PRIOR_ARTIFACT_MUTATION=
  NOT_ALLOWED

CURRENT_ARTIFACT_MUTATION=
  NOT_ALLOWED

SELECTED_HISTORY_CHANGE=
  NONE

PROJECT_CONTEXT_CHANGE=
  NONE

PRIOR_LIFECYCLE_SELECTION_CHANGE=
  NONE

WORKFLOW_IEL_PERSISTENCE_OWNERSHIP=
  PRESERVED

MATILDA_SEMANTIC_AUTHORITY=
  PRESERVED

ONE_OLLAMA_INVOCATION=
  PRESERVED

FAILURE_BOUNDARY_CLASSIFICATION=
  INVALID_CROSS_TURN_RELATIONSHIP_IS_A_BOUNDED_VALIDATION_FAILURE

FAILURE_SEMANTICS=
  The current Matilda-authored lifecycle artifact must first satisfy existing
  structural validation.

  If prior lifecycle state exists, deterministic cross-turn validation then
  evaluates only the relationship between the prior artifact and the current
  artifact.

  An invalid relationship fails closed before durable persistence of the
  current lifecycle artifact.

  Runtime must not repair, rewrite, synthesize, retry, or invoke the model
  again to resolve the invalid relationship.

  This preserves Matilda's semantic authorship while preventing an invalid
  cross-turn lifecycle transition from becoming durable state.

VALIDATION_TIMING_AND_FAILURE_BOUNDARY_CORRIDOR=
  COMPLETE

IMPLEMENTATION_READINESS=
  NOT_YET_ESTABLISHED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

NEXT_CORRIDOR=
  PERSISTENCE_AND_AUTHORSHIP_PRESERVATION

NEXT_ACTION=
  CLASSIFY_PERSISTENCE_AND_AUTHORSHIP_PRESERVATION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-validation-timing-and-failure-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside validation timing/failure scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
