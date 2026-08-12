#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY POST SEMANTIC HISTORY SUCCESSOR MILESTONE ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="c7ca6b64"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches post-semantic-history reconciliation checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-post-semantic-history-successor-milestone\.sh$|^ M scripts/classify-post-semantic-history-successor-milestone\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "POST_SEMANTIC_HISTORY_RECONCILIATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CLOSED PREDECESSOR STATE ==="

grep -q 'GENERATION_STABILITY=' scripts/reconcile-post-semantic-history-context-optimization-program-state.sh
grep -q 'SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=' scripts/reconcile-post-semantic-history-context-optimization-program-state.sh
grep -q 'SUCCESSOR_MILESTONE=' scripts/reconcile-post-semantic-history-context-optimization-program-state.sh
grep -q 'NOT_YET_CLASSIFIED' scripts/reconcile-post-semantic-history-context-optimization-program-state.sh

echo "CLOSED_PREDECESSOR_STATE=CONFIRMED"

echo
echo "=== SUCCESSOR MILESTONE CLASSIFICATION ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

PREDECESSOR_MILESTONE_1=
  GENERATION_STABILITY
STATUS=
  CLOSED

PREDECESSOR_MILESTONE_2=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION
STATUS=
  CLOSED

DEFERRED_PRODUCTION_GENERATION_INSTABILITY=
  PRESERVED_AS_KNOWN_CONDITION

NEW_RUNTIME_REGRESSION=
  NOT_ESTABLISHED

NEW_SEMANTIC_HISTORY_OPTIMIZATION_REQUIREMENT=
  NOT_ESTABLISHED

SUCCESSOR_MILESTONE_EVIDENCE=
  INSUFFICIENT_FOR_RUNTIME_IMPLEMENTATION_SELECTION

SUCCESSOR_MILESTONE=
  CONVERSATION_ENGINE_PROGRAM_RECONCILIATION_AND_NEXT_CAPABILITY_DETERMINATION

SUCCESSOR_MILESTONE_CLASS=
  INVESTIGATION_AND_PROGRAM_BOUNDARY_CLASSIFICATION

RATIONALE=
  The two immediately preceding milestones are closed.

  Generation Stability established a deferred production generation-instability
  condition without establishing a production runtime regression.

  Semantic History Context Optimization completed without establishing a new
  semantic-history runtime optimization requirement.

  Therefore the next safe program step is not another implementation corridor.
  The repository should first reconcile remaining deferred capabilities,
  completed runtime surfaces, and unresolved program-level capability gaps to
  determine the next evidence-supported milestone.

PHASE_1=
  CURRENT_CAPABILITY_AND_DEFERRED_WORK_RECONCILIATION

PHASE_1_CORRIDOR_1=
  COMPLETED_RUNTIME_CAPABILITY_INVENTORY

PHASE_1_CORRIDOR_2=
  DEFERRED_WORK_INVENTORY

PHASE_1_CORRIDOR_3=
  UNRESOLVED_CAPABILITY_GAP_CLASSIFICATION

PHASE_1_CORRIDOR_4=
  SUCCESSOR_PRIORITY_BOUNDARY

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

SUCCESSOR_MILESTONE_CLASSIFICATION=
  COMPLETE

NEXT_PHASE=
  CURRENT_CAPABILITY_AND_DEFERRED_WORK_RECONCILIATION

NEXT_CORRIDOR=
  COMPLETED_RUNTIME_CAPABILITY_INVENTORY

NEXT_ACTION=
  CLASSIFY_COMPLETED_RUNTIME_CAPABILITY_INVENTORY
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-post-semantic-history-successor-milestone\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside successor milestone classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
