#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY UNRESOLVED CAPABILITY GAPS ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="7c442267"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches deferred-work inventory checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-unresolved-capability-gaps\.sh$|^ M scripts/classify-unresolved-capability-gaps\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "DEFERRED_WORK_INVENTORY_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING INVENTORIES ==="

grep -q 'COMPLETED_RUNTIME_CAPABILITY_INVENTORY_STATUS=' scripts/classify-completed-runtime-capability-inventory.sh
grep -q 'COMPLETE' scripts/classify-completed-runtime-capability-inventory.sh

grep -q 'DEFERRED_WORK_INVENTORY_STATUS=' scripts/classify-deferred-work-inventory.sh
grep -q 'COMPLETE' scripts/classify-deferred-work-inventory.sh

echo "GOVERNING_INVENTORIES=CONFIRMED"

echo
echo "=== UNRESOLVED CAPABILITY GAP CLASSIFICATION ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

MILESTONE=
  CONVERSATION_ENGINE_PROGRAM_RECONCILIATION_AND_NEXT_CAPABILITY_DETERMINATION

PHASE=
  CURRENT_CAPABILITY_AND_DEFERRED_WORK_RECONCILIATION

CORRIDOR=
  UNRESOLVED_CAPABILITY_GAP_CLASSIFICATION

CLASSIFICATION_RULE=
  A capability is classified as an unresolved gap only when the repository
  identifies a missing behavior or validation boundary whose intended
  architectural role is already established.

DEFERRED_PRODUCTION_GENERATION_INSTABILITY=
  KNOWN_CONDITION_NOT_CAPABILITY_GAP

SEMANTIC_HISTORY_RANKING=
  NOT_A_CURRENT_GAP_REQUIREMENT_NOT_ESTABLISHED

TOKEN_BUDGET_CONTROL=
  NOT_A_CURRENT_GAP_REQUIREMENT_NOT_ESTABLISHED

HISTORY_WINDOW_CHANGE=
  NOT_A_CURRENT_GAP_CHANGE_REQUIREMENT_NOT_ESTABLISHED

HYBRID_CONTEXT_COORDINATION=
  NOT_A_CURRENT_GAP_REQUIREMENT_NOT_ESTABLISHED

MODEL_RUNTIME_CONTEXT_CONFIGURATION=
  NOT_A_CURRENT_GAP_CHANGE_REQUIREMENT_NOT_ESTABLISHED

INTEGRATED_OPTIMIZATION_LAYER=
  NOT_A_CURRENT_GAP_REQUIREMENT_NOT_ESTABLISHED

EVALUATED_INTERPRETATIONS_SURFACING=
  NOT_A_RUNTIME_CAPABILITY_GAP_IMPLEMENTED_BUT_NOT_INDEPENDENTLY_SURFACED

CONTAMINATION_EVALUATIONS_SURFACING=
  NOT_A_RUNTIME_CAPABILITY_GAP_IMPLEMENTED_BUT_NOT_INDEPENDENTLY_SURFACED

INTERPRETATION_AUTHORITY_LIFECYCLE_STATE_SURFACING=
  NOT_A_RUNTIME_CAPABILITY_GAP_IMPLEMENTED_BUT_NOT_INDEPENDENTLY_SURFACED

RECONSTRUCTED_INVESTIGATION_LIFECYCLE_STATE_SURFACING=
  NOT_A_RUNTIME_CAPABILITY_GAP_IMPLEMENTED_BUT_NOT_INDEPENDENTLY_SURFACED

SELECTED_PRIOR_INVESTIGATION_LIFECYCLE_CONTEXT_SURFACING=
  NOT_A_RUNTIME_CAPABILITY_GAP_IMPLEMENTED_BUT_NOT_INDEPENDENTLY_SURFACED

RECOVERY_AND_CORRELATION_REFINEMENTS=
  DEFERRED_REFINEMENT_REQUIREMENT_NOT_YET_ESTABLISHED

PROMPT_EVOLUTION=
  DEFERRED_REFINEMENT_REQUIREMENT_NOT_YET_ESTABLISHED

CROSS_TURN_INVESTIGATION_LIFECYCLE_TRANSITION_VALIDATION=
  UNRESOLVED_CAPABILITY_GAP

GAP_RATIONALE=
  Investigation Lifecycle current-turn transport, reconstruction, scoped prior
  lifecycle selection, and typed prior-lifecycle context transport are already
  implemented.

  The lifecycle event vocabulary and semantic artifact contract are established.

  Cross-turn transition validation remains explicitly deferred and is the only
  currently inventoried item that represents a missing validation behavior
  inside an already-established architectural lifecycle boundary.

  This classification does not establish implementation readiness or priority.

UNRESOLVED_CAPABILITY_GAP_COUNT=
  ONE

PRIMARY_UNRESOLVED_CAPABILITY_GAP=
  CROSS_TURN_INVESTIGATION_LIFECYCLE_TRANSITION_VALIDATION

IMPLEMENTATION_READINESS=
  NOT_YET_CLASSIFIED

PRIORITY=
  NOT_YET_CLASSIFIED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

UNRESOLVED_CAPABILITY_GAP_CLASSIFICATION_STATUS=
  COMPLETE

NEXT_CORRIDOR=
  SUCCESSOR_PRIORITY_BOUNDARY

NEXT_ACTION=
  CLASSIFY_SUCCESSOR_PRIORITY_BOUNDARY
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-unresolved-capability-gaps\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside unresolved capability gap classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
