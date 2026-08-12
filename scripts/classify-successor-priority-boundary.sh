#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY SUCCESSOR PRIORITY BOUNDARY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="bb7076d1"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches unresolved-gap checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-successor-priority-boundary\.sh$|^ M scripts/classify-successor-priority-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "UNRESOLVED_GAP_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING CLASSIFICATIONS ==="

grep -q 'UNRESOLVED_CAPABILITY_GAP_COUNT=' scripts/classify-unresolved-capability-gaps.sh
grep -q 'PRIMARY_UNRESOLVED_CAPABILITY_GAP=' scripts/classify-unresolved-capability-gaps.sh
grep -q 'CROSS_TURN_INVESTIGATION_LIFECYCLE_TRANSITION_VALIDATION' scripts/classify-unresolved-capability-gaps.sh
grep -q 'IMPLEMENTATION_READINESS=' scripts/classify-unresolved-capability-gaps.sh
grep -q 'NOT_YET_CLASSIFIED' scripts/classify-unresolved-capability-gaps.sh

echo "GOVERNING_CLASSIFICATIONS=CONFIRMED"

echo
echo "=== SUCCESSOR PRIORITY BOUNDARY ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

MILESTONE=
  CONVERSATION_ENGINE_PROGRAM_RECONCILIATION_AND_NEXT_CAPABILITY_DETERMINATION

PHASE=
  CURRENT_CAPABILITY_AND_DEFERRED_WORK_RECONCILIATION

CORRIDOR=
  SUCCESSOR_PRIORITY_BOUNDARY

CURRENT_GENUINE_UNRESOLVED_CAPABILITY_GAPS=
  ONE

PRIMARY_UNRESOLVED_CAPABILITY_GAP=
  CROSS_TURN_INVESTIGATION_LIFECYCLE_TRANSITION_VALIDATION

OTHER_DEFERRED_ITEMS=
  NOT_CURRENTLY_ESTABLISHED_AS_CAPABILITY_GAPS

PRIORITY_BASIS=
  The repository currently identifies one missing behavior inside an already
  established architectural boundary.

  Investigation Lifecycle current-turn transport, reconstruction, scoped prior
  lifecycle selection, typed prior-lifecycle context transport, lifecycle event
  vocabulary, and semantic artifact ownership are already established.

  Cross-turn transition validation is the remaining missing validation boundary
  within that lifecycle capability.

  Other deferred items either have no established requirement, represent known
  conditions rather than capability gaps, or are implemented but not surfaced.

SUCCESSOR_PRIORITY=
  CROSS_TURN_INVESTIGATION_LIFECYCLE_TRANSITION_VALIDATION

SUCCESSOR_PRIORITY_CLASSIFICATION=
  HIGHEST_EVIDENCE_SUPPORTED_UNRESOLVED_CAPABILITY

NEXT_MILESTONE_CANDIDATE=
  INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION

IMPLEMENTATION_READINESS=
  NOT_ESTABLISHED

IMPLEMENTATION_AUTHORIZATION=
  NOT_GRANTED

REQUIRED_NEXT_STEP=
  INVESTIGATE_AND_CLASSIFY_IMPLEMENTATION_READINESS

PRIORITY_BOUNDARY_STATUS=
  COMPLETE

PHASE_1_STATUS=
  COMPLETE

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

NEXT_PHASE=
  SUCCESSOR_CAPABILITY_READINESS_CLASSIFICATION

NEXT_CORRIDOR=
  CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION_READINESS

NEXT_ACTION=
  INVESTIGATE_AND_CLASSIFY_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION_READINESS
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-successor-priority-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside successor priority boundary scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
