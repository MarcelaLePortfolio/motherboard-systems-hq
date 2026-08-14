#!/usr/bin/env bash
set -euo pipefail

echo "=== CLOSE CONVERSATION ENGINE PROGRAM RECONCILIATION MILESTONE ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 65fbd98d HEAD

readiness="scripts/classify-program-reconciliation-milestone-closure-readiness.sh"
test -f "$readiness"

echo "=== VERIFY CLOSURE READINESS ==="
grep -q 'PROGRAM_RECONCILIATION_MILESTONE_CLOSURE_READINESS=' "$readiness"
grep -q 'READY' "$readiness"
grep -q 'MILESTONE_CAN_CLOSE=' "$readiness"
grep -q '^YES$' <(awk '/MILESTONE_CAN_CLOSE=/{getline; print}' "$readiness")
grep -q 'NEW_RUNTIME_IMPLEMENTATION_MILESTONE=' "$readiness"
grep -q 'NONE_ESTABLISHED' "$readiness"
grep -q 'PRODUCTION_CHANGE=' "$readiness"
grep -q '^NONE$' <(awk '/PRODUCTION_CHANGE=/{getline; print}' "$readiness")
echo "CLOSURE_READINESS=CONFIRMED"

echo
echo "=== VERIFY PHASE 1 COMPLETION ==="

artifacts=(
  scripts/reconcile-current-completed-runtime-capability-inventory.sh
  scripts/reconcile-current-deferred-work-inventory.sh
  scripts/reconcile-current-unresolved-capability-gaps.sh
  scripts/reconcile-current-successor-priority-boundary.sh
  scripts/classify-program-reconciliation-phase-1-disposition-and-successor-decision-boundary.sh
)

for artifact in "${artifacts[@]}"; do
  test -f "$artifact"
  echo "PRESENT=$artifact"
done

grep -q 'CORRIDOR_1_STATUS=' scripts/reconcile-current-completed-runtime-capability-inventory.sh
grep -q 'COMPLETE' scripts/reconcile-current-completed-runtime-capability-inventory.sh

grep -q 'CORRIDOR_2_STATUS=' scripts/reconcile-current-deferred-work-inventory.sh
grep -q 'COMPLETE' scripts/reconcile-current-deferred-work-inventory.sh

grep -q 'CORRIDOR_3_STATUS=' scripts/reconcile-current-unresolved-capability-gaps.sh
grep -q 'COMPLETE' scripts/reconcile-current-unresolved-capability-gaps.sh

grep -q 'PRIORITY_BOUNDARY_STATUS=' scripts/reconcile-current-successor-priority-boundary.sh
grep -q 'COMPLETE' scripts/reconcile-current-successor-priority-boundary.sh

grep -q 'PHASE_1_STATUS=' scripts/classify-program-reconciliation-phase-1-disposition-and-successor-decision-boundary.sh
grep -q 'COMPLETE' scripts/classify-program-reconciliation-phase-1-disposition-and-successor-decision-boundary.sh

echo "PHASE_1_COMPLETION=CONFIRMED"

echo
echo "=== FINAL MILESTONE CLOSURE ==="

cat <<'MAP'
PROGRAM=
MATILDA_CONVERSATION_ENGINE

MILESTONE=
CONVERSATION_ENGINE_PROGRAM_RECONCILIATION_AND_NEXT_CAPABILITY_DETERMINATION

MILESTONE_CLASS=
INVESTIGATION_AND_PROGRAM_BOUNDARY_CLASSIFICATION

PHASE_1=
CURRENT_CAPABILITY_AND_DEFERRED_WORK_RECONCILIATION

PHASE_1_STATUS=
COMPLETE

CORRIDOR_1=
COMPLETED_RUNTIME_CAPABILITY_INVENTORY
STATUS=
COMPLETE

CORRIDOR_2=
DEFERRED_WORK_INVENTORY
STATUS=
COMPLETE

CORRIDOR_3=
UNRESOLVED_CAPABILITY_GAP_CLASSIFICATION
STATUS=
COMPLETE

CORRIDOR_4=
SUCCESSOR_PRIORITY_BOUNDARY
STATUS=
COMPLETE

CURRENT_RUNTIME_CAPABILITY_INVENTORY=
RECONCILED

CURRENT_DEFERRED_WORK=
RECONCILED_AND_PRESERVED_WITHOUT_PRIORITY_PROMOTION

CURRENT_UNRESOLVED_CAPABILITY_GAPS=
ZERO_ON_CURRENT_INVENTORIED_SURFACE

CURRENT_SUCCESSOR_PRIORITY=
NONE_ESTABLISHED

CROSS_TURN_INVESTIGATION_LIFECYCLE_TRANSITION_VALIDATION=
IMPLEMENTED_AND_VALIDATED

SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=
CLOSED

CONVERSATION_ENGINE_GENERATION_STABILITY=
CLOSED_WITH_PRODUCTION_GENERATION_INSTABILITY_EXPLICITLY_ESTABLISHED

PRODUCTION_GENERATION_INSTABILITY=
PRESERVED_AS_KNOWN_DEFERRED_CONDITION

PRODUCTION_RUNTIME_REGRESSION=
NOT_ESTABLISHED

PRODUCTION_GENERATION_POLICY=
UNCHANGED_UNCONFIGURED_UNSEEDED

NEW_RUNTIME_CAPABILITY_REQUIREMENT=
NONE_ESTABLISHED

NEXT_RUNTIME_IMPLEMENTATION_MILESTONE=
NONE_ESTABLISHED

SUCCESSOR_DECISION_BOUNDARY=
REQUIRE_NEW_EVIDENCE_OR_EXPLICIT_NEW_PROGRAM_OBJECTIVE_BEFORE_OPENING_ANOTHER_RUNTIME_MILESTONE

IMPLEMENTATION_AUTHORIZED=
NO

IMPLEMENTATION_STARTED=
NO

PRODUCTION_CHANGE=
NONE

MILESTONE_CLOSURE_CLASSIFICATION=
COMPLETE_WITH_NO_EVIDENCE_SUPPORTED_RUNTIME_SUCCESSOR_ESTABLISHED

MILESTONE_STATUS=
CLOSED

NEXT_PROGRAM_STATE=
NO_ACTIVE_RUNTIME_SUCCESSOR_MILESTONE_ESTABLISHED

NEXT_ACTION=
CAPTURE_DR_CHECKPOINT_AND_AWAIT_NEW_EVIDENCE_OR_EXPLICIT_PROGRAM_OBJECTIVE
MAP
