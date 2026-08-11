#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PHASE 1 SEMANTIC SELECTION OPTIMIZATION DISPOSITION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

expected_head="76af49ae"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches reconciled program-state checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-1-semantic-selection-optimization-disposition\.sh$|^ M scripts/classify-phase-1-semantic-selection-optimization-disposition\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "PROGRAM_STATE_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY SEMANTIC HISTORY RESUME STATE ==="

grep -nE \
  'SEMANTIC_HISTORY_MILESTONE_STATUS=|ACTIVE|SEMANTIC_HISTORY_CURRENT_PHASE=|PHASE_1_SEMANTIC_SELECTION_OPTIMIZATION|SEMANTIC_HISTORY_CURRENT_CORRIDOR=|SEMANTIC_RANKING_REQUIREMENT|NEXT_ACTION=|RESUME_SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION_FROM_SEMANTIC_RANKING_REQUIREMENT_CHECKPOINT' \
  scripts/reconcile-post-generation-stability-program-state.sh

echo "SEMANTIC_HISTORY_RESUME_STATE=CONFIRMED"

echo
echo "=== VERIFY RANKING REQUIREMENT RESULT ==="

grep -nE \
  'SEMANTIC_RANKING_REQUIREMENT=|NOT_ESTABLISHED|SEMANTIC_RANKING_IMPLEMENTATION=|NOT_AUTHORIZED|SEMANTIC_RANKING_OWNERSHIP_CLASSIFICATION_REQUIRED=|NO_WHILE_REQUIREMENT_REMAINS_UNESTABLISHED|RANKING_INPUT_AND_OUTPUT_BOUNDARY_CLASSIFICATION_REQUIRED=|NO_WHILE_REQUIREMENT_REMAINS_UNESTABLISHED|SEMANTIC_RANKING_REQUIREMENT_CORRIDOR=|COMPLETE_WITH_REQUIREMENT_NOT_ESTABLISHED' \
  scripts/classify-semantic-ranking-requirement.sh

echo "RANKING_REQUIREMENT_RESULT=CONFIRMED"

echo
echo "=== PHASE 1 DISPOSITION ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

PHASE=
  SEMANTIC_SELECTION_OPTIMIZATION

CORRIDOR_1=
  SEMANTIC_RANKING_REQUIREMENT
  STATUS=COMPLETE_WITH_REQUIREMENT_NOT_ESTABLISHED

CORRIDOR_2=
  SEMANTIC_RANKING_OWNERSHIP
  STATUS=NOT_REQUIRED

CORRIDOR_3=
  RANKING_INPUT_AND_OUTPUT_BOUNDARY
  STATUS=NOT_REQUIRED

CORRIDOR_4=
  CHRONOLOGY_AND_LINEAGE_PRESERVATION
  STATUS=SATISFIED_BY_EXISTING_IMPLEMENTED_CONTRACT

CORRIDOR_5=
  SEMANTIC_SELECTION_VALIDATION
  STATUS=SATISFIED_BY_EXISTING_BEHAVIORAL_VALIDATION

PHASE_1_RESULT=
  COMPLETE_WITH_NO_SEMANTIC_RANKING_REQUIREMENT_ESTABLISHED

RATIONALE=
  Comparative semantic ranking is absent from the active history-selection path.

  Absence alone does not establish a missing capability.

  Repository evidence did not establish an architectural or behavioral requirement
  for comparative semantic ranking.

  Because the requirement is unestablished, ranking ownership and ranking
  input/output boundary classification are unnecessary.

  Existing semantic-history validation already establishes preservation of
  chronology, lineage, authority, contamination, and selectedHistory behavior.

SEMANTIC_RANKING_IMPLEMENTATION=
  NOT_AUTHORIZED

EXISTING_SELECTION_MODEL=
  PRESERVE

AUTHORITY_EVALUATION=
  PRESERVE

CONTAMINATION_EVALUATION=
  PRESERVE

SELECTED_HISTORY=
  PRESERVE

CHRONOLOGY_AND_LINEAGE=
  PRESERVE

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

PHASE_1_STATUS=
  COMPLETE

NEXT_PHASE=
  CONTEXT_BUDGET_AND_WINDOW_OPTIMIZATION

NEXT_CORRIDOR=
  TOKEN_BUDGET_REQUIREMENT

NEXT_ACTION=
  CLASSIFY_TOKEN_BUDGET_REQUIREMENT
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-1-semantic-selection-optimization-disposition\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 1 disposition scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
