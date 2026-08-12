#!/usr/bin/env bash
set -euo pipefail

echo "=== INVESTIGATE CROSS-TURN TRANSITION VALIDATION IMPLEMENTATION READINESS ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="f1af436b"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches successor priority checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-cross-turn-transition-validation-implementation-readiness\.sh$|^ M scripts/investigate-cross-turn-transition-validation-implementation-readiness\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "SUCCESSOR_PRIORITY_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING GAP ==="

grep -q 'SUCCESSOR_PRIORITY=' scripts/classify-successor-priority-boundary.sh
grep -q 'CROSS_TURN_INVESTIGATION_LIFECYCLE_TRANSITION_VALIDATION' scripts/classify-successor-priority-boundary.sh
grep -q 'IMPLEMENTATION_READINESS=' scripts/classify-successor-priority-boundary.sh
grep -q 'NOT_ESTABLISHED' scripts/classify-successor-priority-boundary.sh

echo "GOVERNING_GAP=CONFIRMED"

echo
echo "=== DISCOVER ACTUAL LIFECYCLE SURFACES ==="

workflow_file="server/matilda-chat-workflow.ts"

if [[ ! -f "$workflow_file" ]]; then
  echo "STOP: workflow surface missing: $workflow_file"
  exit 2
fi

validator_matches="$(
  rg -l \
    'validateMatildaInvestigationLifecycleArtifact' \
    server scripts/utils \
    --glob '*.ts' \
    --glob '!*.test.ts' \
    2>/dev/null || true
)"

if [[ -z "$validator_matches" ]]; then
  echo "STOP: shared Investigation Lifecycle validator implementation surface not found."
  exit 2
fi

validator_file="$(
  printf '%s\n' "$validator_matches" |
  head -1
)"

current_lifecycle_matches="$(
  rg -n \
    'investigationLifecycle' \
    "$workflow_file" \
    2>/dev/null || true
)"

prior_lifecycle_matches="$(
  rg -n \
    'priorInvestigationLifecycle' \
    "$workflow_file" \
    2>/dev/null || true
)"

if [[ -z "$current_lifecycle_matches" ]]; then
  echo "STOP: current-turn Investigation Lifecycle workflow transport not found."
  exit 2
fi

if [[ -z "$prior_lifecycle_matches" ]]; then
  echo "STOP: prior Investigation Lifecycle workflow transport not found."
  exit 2
fi

transition_matches="$(
  rg -n \
    'transition|previous.*lifecycleEvent|prior.*lifecycleEvent|cross[-_ ]turn' \
    server \
    --glob '*.ts' \
    2>/dev/null || true
)"

echo "WORKFLOW_SURFACE=$workflow_file"
echo "SHARED_LIFECYCLE_VALIDATOR_SURFACE=$validator_file"
echo "CURRENT_LIFECYCLE_TRANSPORT=CONFIRMED"
echo "PRIOR_LIFECYCLE_TRANSPORT=CONFIRMED"

if [[ -n "$transition_matches" ]]; then
  echo "TRANSITION_RELATED_REPOSITORY_REFERENCES=PRESENT"
else
  echo "TRANSITION_RELATED_REPOSITORY_REFERENCES=ABSENT"
fi

echo
echo "=== READINESS CLASSIFICATION ==="

cat <<MAP
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

MILESTONE_CANDIDATE=
  INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION

PHASE=
  SUCCESSOR_CAPABILITY_READINESS_CLASSIFICATION

CORRIDOR=
  CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION_READINESS

WORKFLOW_SURFACE=
  $workflow_file

SHARED_LIFECYCLE_VALIDATOR_SURFACE=
  $validator_file

CURRENT_TURN_LIFECYCLE_ARTIFACT=
  IMPLEMENTED

PRIOR_LIFECYCLE_RECONSTRUCTION=
  IMPLEMENTED

PRIOR_LIFECYCLE_SCOPED_SELECTION=
  IMPLEMENTED

PRIOR_LIFECYCLE_TYPED_TRANSPORT=
  IMPLEMENTED

SHARED_LIFECYCLE_ARTIFACT_VALIDATOR=
  IMPLEMENTED

CURRENT_AND_PRIOR_LIFECYCLE_STATE_AVAILABLE_TO_WORKFLOW=
  YES

CROSS_TURN_TRANSITION_VALIDATOR=
  NOT_ESTABLISHED_AS_IMPLEMENTED

IMPLEMENTATION_SURFACE_AVAILABILITY=
  SUFFICIENT_FOR_TRANSITION_RULE_AND_OWNERSHIP_CLASSIFICATION

IMPLEMENTATION_READINESS=
  NOT_YET_ESTABLISHED

READINESS_BOUNDARY=
  The repository exposes both current and prior typed Investigation Lifecycle
  artifacts at the workflow boundary and contains a shared bounded lifecycle
  artifact validator.

  The earlier failed investigation assumed a nonexistent file path and did not
  establish any missing runtime surface.

  Repository discovery now confirms the required lifecycle inputs exist without
  assuming where the shared validator is implemented.

  Cross-turn transition legality, validator ownership, validation timing,
  failure behavior, and persistence interaction remain to be classified before
  implementation readiness can be established.

NEXT_REQUIRED_CLASSIFICATIONS=
  TRANSITION_RULE_REQUIREMENT
  TRANSITION_VALIDATOR_OWNERSHIP
  VALIDATION_TIMING_AND_FAILURE_BOUNDARY
  PERSISTENCE_AND_AUTHORSHIP_PRESERVATION
  IMPLEMENTATION_READINESS_DISPOSITION

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

READINESS_INVESTIGATION_STATUS=
  COMPLETE

NEXT_CORRIDOR=
  CROSS_TURN_TRANSITION_RULE_REQUIREMENT

NEXT_ACTION=
  CLASSIFY_CROSS_TURN_TRANSITION_RULE_REQUIREMENT
MAP

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-cross-turn-transition-validation-implementation-readiness\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside readiness investigation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
