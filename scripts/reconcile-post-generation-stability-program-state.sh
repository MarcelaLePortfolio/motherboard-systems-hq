#!/usr/bin/env bash
set -euo pipefail

echo "=== RECONCILE POST GENERATION STABILITY PROGRAM STATE ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

expected_head="88dc69e4"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches normalized corridor-map checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-post-generation-stability-program-state\.sh$|^ M scripts/reconcile-post-generation-stability-program-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "NORMALIZED_CORRIDOR_MAP_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GENERATION STABILITY CLOSURE ==="

grep -nE \
  'GENERATION_STABILITY_MILESTONE=|REMAINS_CLOSED|NO_GENERATION_VARIANCE_WORK_MISSING|SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=|SEPARATE_MILESTONE' \
  scripts/reconcile-generation-stability-normalized-corridor-map.sh

echo "GENERATION_STABILITY_STATE=CONFIRMED"

echo
echo "=== VERIFY SEMANTIC HISTORY WORK EXISTS AFTER CLOSURE ==="

if ! git merge-base --is-ancestor d757ab0a 6df7560b; then
  echo "STOP: semantic-history phase-map checkpoint is not downstream of Generation Stability closure."
  exit 2
fi

if ! git merge-base --is-ancestor 6df7560b f5e136f5; then
  echo "STOP: semantic-ranking requirement checkpoint is not downstream of semantic-history phase-map discovery."
  exit 2
fi

echo "SEMANTIC_HISTORY_POST_CLOSURE_LINEAGE=CONFIRMED"

echo
echo "=== RECONCILED PROGRAM STATE ==="

cat <<'MAP'
COMPLETED_MILESTONE=
  CONVERSATION_ENGINE_GENERATION_STABILITY

COMPLETED_MILESTONE_STATUS=
  CLOSED

NORMALIZED_PHASE_1_CORRIDORS=
  PRODUCTION_BASELINE=COMPLETE
  GENERATION_VARIANCE=COMPLETE
  FAILURE_CHARACTERIZATION=COMPLETE
  DIAGNOSTIC_CONTROLS=COMPLETE
  STABILITY_DETERMINATION=COMPLETE

GENERATION_STABILITY_FINAL_RESULT=
  COMPLETE_WITH_PRODUCTION_GENERATION_INSTABILITY_EXPLICITLY_ESTABLISHED

UNQUALIFIED_PRODUCTION_STABLE=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

DEFERRED_PRODUCTION_CONDITION=
  GENERATION_INSTABILITY_REMAINS

DEFERRED_PRODUCTION_POLICY_PROMOTION=
  PRESERVE

POST_CLOSURE_MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

POST_CLOSURE_MILESTONE_RELATIONSHIP=
  SEPARATE_FROM_GENERATION_STABILITY

SEMANTIC_HISTORY_MILESTONE_STATUS=
  ACTIVE

SEMANTIC_HISTORY_PHASE_MAP=
  PRESERVE

SEMANTIC_HISTORY_CURRENT_PHASE=
  PHASE_1_SEMANTIC_SELECTION_OPTIMIZATION

SEMANTIC_HISTORY_CURRENT_CORRIDOR=
  SEMANTIC_RANKING_REQUIREMENT

SEMANTIC_RANKING_REQUIREMENT_CHECKPOINT=
  f5e136f5

GENERATION_STABILITY_REOPEN_REQUIRED=
  NO

GENERATION_VARIANCE_REOPEN_REQUIRED=
  NO

SEMANTIC_HISTORY_WORK_REVERT_REQUIRED=
  NO

IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_CHANGE=
  NONE

PROGRAM_STATE_RECONCILIATION=
  COMPLETE

NEXT_ACTION=
  RESUME_SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION_FROM_SEMANTIC_RANKING_REQUIREMENT_CHECKPOINT
MAP

echo
echo "=== VERIFY RECONCILIATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-post-generation-stability-program-state\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside program-state reconciliation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "RECONCILIATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
