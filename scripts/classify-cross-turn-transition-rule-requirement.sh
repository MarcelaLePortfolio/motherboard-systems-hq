#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY CROSS-TURN TRANSITION RULE REQUIREMENT ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="fb5f87dd"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches readiness investigation checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-cross-turn-transition-rule-requirement\.sh$|^ M scripts/classify-cross-turn-transition-rule-requirement\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "READINESS_INVESTIGATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING READINESS STATE ==="

grep -q 'READINESS_INVESTIGATION_STATUS=' scripts/investigate-cross-turn-transition-validation-implementation-readiness.sh
grep -q 'COMPLETE' scripts/investigate-cross-turn-transition-validation-implementation-readiness.sh
grep -q 'CURRENT_AND_PRIOR_LIFECYCLE_STATE_AVAILABLE_TO_WORKFLOW=' scripts/investigate-cross-turn-transition-validation-implementation-readiness.sh
grep -q 'YES' scripts/investigate-cross-turn-transition-validation-implementation-readiness.sh

echo "GOVERNING_READINESS_STATE=CONFIRMED"

echo
echo "=== CLASSIFY TRANSITION RULE REQUIREMENT ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

MILESTONE_CANDIDATE=
  INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION

PHASE=
  SUCCESSOR_CAPABILITY_READINESS_CLASSIFICATION

CORRIDOR=
  CROSS_TURN_TRANSITION_RULE_REQUIREMENT

CURRENT_TURN_LIFECYCLE_ARTIFACT=
  IMPLEMENTED

PRIOR_LIFECYCLE_CONTEXT=
  IMPLEMENTED

LIFECYCLE_EVENT_VOCABULARY=
  ESTABLISHED

LIFECYCLE_EVENTS=
  ENTERED
  CONTINUED
  ADVANCED
  RESOLVED
  SUPERSEDED
  ABANDONED

ADVANCED_REQUIRES_DETERMINATION=
  YES

RESOLVED_REQUIRES_DETERMINATION=
  YES

CURRENT_ARTIFACT_VALIDATION=
  IMPLEMENTED

CROSS_TURN_RELATIONSHIP_VALIDATION=
  NOT_IMPLEMENTED

TRANSITION_RULE_REQUIREMENT=
  ESTABLISHED

REQUIREMENT_BASIS=
  Current-turn Investigation Lifecycle artifacts are individually validated,
  but the repository now transports both current and prior Matilda-authored
  lifecycle state across turns.

  Once prior lifecycle state participates in current semantic generation,
  validating only each artifact independently cannot determine whether the
  current lifecycle event is coherent with the immediately prior lifecycle
  state.

  The lifecycle vocabulary contains state-changing events including advanced,
  resolved, superseded, and abandoned, while continued and entered imply
  different continuity semantics.

  Therefore a bounded cross-turn transition rule is required to validate the
  relationship between prior and current lifecycle artifacts without changing
  Matilda's semantic authorship.

TRANSITION_RULE_SCOPE=
  PRIOR_AND_CURRENT_INVESTIGATION_LIFECYCLE_ARTIFACT_RELATIONSHIP_ONLY

TRANSITION_RULE_MUST_NOT=
  AUTHOR_LIFECYCLE_FACTS
  REWRITE_INVESTIGATION_IDENTITY
  SYNTHESIZE_LIFECYCLE_EVENTS
  MODIFY_SELECTED_HISTORY
  MODIFY_PROJECT_CONTEXT
  MODIFY_PRIOR_LIFECYCLE_CONTEXT
  ADD_MODEL_INVOCATIONS

DETERMINISTIC_RUNTIME_ROLE=
  VALIDATE_RELATIONSHIP_ONLY

MATILDA_ROLE=
  RETAIN_SEMANTIC_AUTHORSHIP

TRANSITION_RULE_IMPLEMENTATION=
  NOT_YET_AUTHORIZED

IMPLEMENTATION_READINESS=
  NOT_YET_ESTABLISHED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

TRANSITION_RULE_REQUIREMENT_CORRIDOR=
  COMPLETE_WITH_REQUIREMENT_ESTABLISHED

NEXT_CORRIDOR=
  TRANSITION_VALIDATOR_OWNERSHIP

NEXT_ACTION=
  CLASSIFY_TRANSITION_VALIDATOR_OWNERSHIP
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-cross-turn-transition-rule-requirement\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside transition-rule requirement scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
