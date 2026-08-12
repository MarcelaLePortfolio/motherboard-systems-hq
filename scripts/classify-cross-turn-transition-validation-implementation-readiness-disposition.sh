#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY CROSS-TURN TRANSITION VALIDATION IMPLEMENTATION READINESS DISPOSITION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="160fe122"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches persistence/authorship checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-cross-turn-transition-validation-implementation-readiness-disposition\.sh$|^ M scripts/classify-cross-turn-transition-validation-implementation-readiness-disposition\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "PERSISTENCE_AUTHORSHIP_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY READINESS PREREQUISITES ==="

grep -q 'TRANSITION_RULE_REQUIREMENT_CORRIDOR=' scripts/classify-cross-turn-transition-rule-requirement.sh
grep -q 'COMPLETE_WITH_REQUIREMENT_ESTABLISHED' scripts/classify-cross-turn-transition-rule-requirement.sh

grep -q 'TRANSITION_VALIDATOR_OWNERSHIP_CORRIDOR=' scripts/classify-transition-validator-ownership.sh
grep -q 'COMPLETE' scripts/classify-transition-validator-ownership.sh

grep -q 'VALIDATION_TIMING_AND_FAILURE_BOUNDARY_CORRIDOR=' scripts/classify-validation-timing-and-failure-boundary.sh
grep -q 'COMPLETE' scripts/classify-validation-timing-and-failure-boundary.sh

grep -q 'PERSISTENCE_AND_AUTHORSHIP_PRESERVATION_CORRIDOR=' scripts/classify-persistence-and-authorship-preservation.sh
grep -q 'COMPLETE' scripts/classify-persistence-and-authorship-preservation.sh

echo "READINESS_PREREQUISITES=CONFIRMED"

echo
echo "=== IMPLEMENTATION READINESS DISPOSITION ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

MILESTONE_CANDIDATE=
  INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION

PHASE=
  SUCCESSOR_CAPABILITY_READINESS_CLASSIFICATION

CORRIDOR=
  IMPLEMENTATION_READINESS_DISPOSITION

TRANSITION_RULE_REQUIREMENT=
  ESTABLISHED

TRANSITION_VALIDATOR_OWNERSHIP=
  CLASSIFIED

VALIDATION_TIMING_AND_FAILURE_BOUNDARY=
  CLASSIFIED

PERSISTENCE_AND_AUTHORSHIP_PRESERVATION=
  CLASSIFIED

CURRENT_AND_PRIOR_LIFECYCLE_INPUTS=
  AVAILABLE

SHARED_DETERMINISTIC_VALIDATION_SURFACE=
  AVAILABLE

DATABASE_SCHEMA_CHANGE_REQUIRED=
  NO

NEW_CONTEXT_CHANNEL_REQUIRED=
  NO

SECOND_MODEL_INVOCATION_REQUIRED=
  NO

PARALLEL_PERSISTENCE_PATH_REQUIRED=
  NO

SEMANTIC_AUTHORSHIP_CHANGE_REQUIRED=
  NO

IMPLEMENTATION_BOUNDARY=
  Add bounded deterministic cross-turn relationship validation between the
  already-selected prior Investigation Lifecycle artifact and the current
  Matilda-authored Investigation Lifecycle artifact.

  Invoke that validation after current structured-response validation and prior
  lifecycle selection, but before durable persistence of the current lifecycle
  artifact.

  Fail closed on invalid relationships without repair, mutation, retry, or
  additional model invocation.

IMPLEMENTATION_READINESS=
  ESTABLISHED

IMPLEMENTATION_SCOPE=
  BOUNDED

IMPLEMENTATION_RISK_CLASS=
  LOCALIZED_VALIDATION_BOUNDARY_CHANGE

PRESERVED_INVARIANTS=
  MATILDA_SEMANTIC_AUTHORSHIP
  WORKFLOW_IEL_PERSISTENCE_OWNERSHIP
  SELECTED_HISTORY
  PROJECT_CONTEXT_EXCERPTS
  PRIOR_LIFECYCLE_SELECTION
  PRIOR_LIFECYCLE_CONTEXT_CHANNEL
  CONVERSATION_CONTEXT_RUNTIME
  REPLY_AND_DURABLE_INTERPRETATION_SEPARATION
  STRUCTURED_RESPONSE_CONTRACT
  LIVING_DRAFT_DERIVATION_FROM_IEL
  APPROVAL_PIPELINE
  ONE_USER_MESSAGE_ONE_WORKFLOW
  ONE_OLLAMA_INVOCATION

READINESS_DISPOSITION=
  READY_FOR_BOUNDED_IMPLEMENTATION_IF_EXPLICITLY_AUTHORIZED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

SUCCESSOR_CAPABILITY_READINESS_CLASSIFICATION_STATUS=
  COMPLETE

NEXT_ACTION=
  AWAIT_EXPLICIT_IMPLEMENTATION_AUTHORIZATION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-cross-turn-transition-validation-implementation-readiness-disposition\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside readiness disposition scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
