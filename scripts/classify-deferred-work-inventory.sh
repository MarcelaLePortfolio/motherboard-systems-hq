#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY DEFERRED WORK INVENTORY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="5278a051"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches completed runtime inventory checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-deferred-work-inventory\.sh$|^ M scripts/classify-deferred-work-inventory\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "COMPLETED_RUNTIME_INVENTORY_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING CORRIDOR ==="

grep -q 'COMPLETED_RUNTIME_CAPABILITY_INVENTORY_STATUS=' scripts/classify-completed-runtime-capability-inventory.sh
grep -q 'COMPLETE' scripts/classify-completed-runtime-capability-inventory.sh
grep -q 'NEXT_CORRIDOR=' scripts/classify-completed-runtime-capability-inventory.sh
grep -q 'DEFERRED_WORK_INVENTORY' scripts/classify-completed-runtime-capability-inventory.sh

echo "GOVERNING_CORRIDOR=CONFIRMED"

echo
echo "=== DEFERRED WORK INVENTORY ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

MILESTONE=
  CONVERSATION_ENGINE_PROGRAM_RECONCILIATION_AND_NEXT_CAPABILITY_DETERMINATION

PHASE=
  CURRENT_CAPABILITY_AND_DEFERRED_WORK_RECONCILIATION

CORRIDOR=
  DEFERRED_WORK_INVENTORY

DEFERRED_PRODUCTION_GENERATION_INSTABILITY=
  PRESENT_AS_KNOWN_CONDITION

PRODUCTION_RUNTIME_REGRESSION=
  NOT_ESTABLISHED

SEMANTIC_HISTORY_RANKING=
  DEFERRED_WITH_REQUIREMENT_NOT_ESTABLISHED

TOKEN_BUDGET_CONTROL=
  DEFERRED_WITH_REQUIREMENT_NOT_ESTABLISHED

HISTORY_WINDOW_CHANGE=
  DEFERRED_WITH_REQUIREMENT_NOT_ESTABLISHED

HYBRID_CONTEXT_COORDINATION=
  DEFERRED_WITH_REQUIREMENT_NOT_ESTABLISHED

MODEL_RUNTIME_CONTEXT_CONFIGURATION=
  DEFERRED_WITH_CHANGE_REQUIREMENT_NOT_ESTABLISHED

INTEGRATED_OPTIMIZATION_LAYER=
  DEFERRED_WITH_REQUIREMENT_NOT_ESTABLISHED

CROSS_TURN_INVESTIGATION_LIFECYCLE_TRANSITION_VALIDATION=
  DEFERRED

EVALUATED_INTERPRETATIONS_SURFACING=
  IMPLEMENTED_BUT_NOT_INDEPENDENTLY_SURFACED

CONTAMINATION_EVALUATIONS_SURFACING=
  IMPLEMENTED_BUT_NOT_INDEPENDENTLY_SURFACED

INTERPRETATION_AUTHORITY_LIFECYCLE_STATE_SURFACING=
  IMPLEMENTED_BUT_NOT_INDEPENDENTLY_SURFACED

RECONSTRUCTED_INVESTIGATION_LIFECYCLE_STATE_SURFACING=
  IMPLEMENTED_BUT_NOT_INDEPENDENTLY_SURFACED

SELECTED_PRIOR_INVESTIGATION_LIFECYCLE_CONTEXT_SURFACING=
  IMPLEMENTED_BUT_NOT_INDEPENDENTLY_SURFACED

RECOVERY_AND_CORRELATION_REFINEMENTS=
  DEFERRED

PROMPT_EVOLUTION=
  DEFERRED

MODEL_RUNTIME_CONTEXT_OPTIMIZATION=
  DEFERRED_WITH_CHANGE_REQUIREMENT_NOT_ESTABLISHED

TWENTY_TURN_WINDOW_OPTIMIZATION=
  DEFERRED_WITH_CHANGE_REQUIREMENT_NOT_ESTABLISHED

DEFERRED_WORK_INVENTORY_INTERPRETATION=
  Deferred work exists in several distinct classes.

  Some items are known future investigation surfaces whose requirement remains
  unestablished.

  Some capabilities are already implemented internally but are not independently
  surfaced.

  Cross-turn Investigation Lifecycle transition validation remains a separately
  deferred runtime-validation capability.

  Production generation instability remains a known condition, but no production
  runtime regression has been established.

  This inventory does not promote any deferred item into an implementation
  requirement and does not assign priority.

DEFERRED_WORK_INVENTORY_STATUS=
  COMPLETE

IMPLEMENTATION_REQUIREMENT_CREATED=
  NO

PRIORITY_ASSIGNED=
  NO

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

NEXT_CORRIDOR=
  UNRESOLVED_CAPABILITY_GAP_CLASSIFICATION

NEXT_ACTION=
  CLASSIFY_UNRESOLVED_CAPABILITY_GAPS
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-deferred-work-inventory\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside deferred work inventory scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
