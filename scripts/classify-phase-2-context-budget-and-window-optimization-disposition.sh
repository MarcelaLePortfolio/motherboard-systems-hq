#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PHASE 2 CONTEXT BUDGET AND WINDOW OPTIMIZATION DISPOSITION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

expected_head="163c811d"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches history-window justification checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-2-context-budget-and-window-optimization-disposition\.sh$|^ M scripts/classify-phase-2-context-budget-and-window-optimization-disposition\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "HISTORY_WINDOW_JUSTIFICATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY TOKEN BUDGET REQUIREMENT RESULT ==="

grep -nE \
  'TOKEN_BUDGET_REQUIREMENT=|NOT_ESTABLISHED|TOKEN_BUDGET_IMPLEMENTATION=|NOT_AUTHORIZED|HISTORY_WINDOW_JUSTIFICATION_REMAINS_REQUIRED=|YES|TOKEN_BUDGET_REQUIREMENT_CORRIDOR=|COMPLETE_WITH_REQUIREMENT_NOT_ESTABLISHED' \
  scripts/classify-token-budget-requirement.sh

echo "TOKEN_BUDGET_REQUIREMENT_RESULT=CONFIRMED"

echo
echo "=== VERIFY HISTORY WINDOW RESULT ==="

grep -nE \
  'CURRENT_PRODUCTION_WINDOW=|20_TURNS|CURRENT_WINDOW_ARCHITECTURAL_RATIONALE=|HISTORY_WINDOW_CHANGE_REQUIREMENT=|NOT_ESTABLISHED|CURRENT_HISTORY_WINDOW=|PRESERVE|BUDGET_AND_WINDOW_INTERACTION_REQUIREMENT=|BUDGET_AND_WINDOW_INTERACTION_CLASSIFICATION_REQUIRED=|HISTORY_WINDOW_JUSTIFICATION_CORRIDOR=|COMPLETE_WITH_CHANGE_REQUIREMENT_NOT_ESTABLISHED' \
  scripts/classify-history-window-justification.sh

echo "HISTORY_WINDOW_RESULT=CONFIRMED"

echo
echo "=== PHASE 2 DISPOSITION ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

PHASE=
  CONTEXT_BUDGET_AND_WINDOW_OPTIMIZATION

CORRIDOR_1=
  TOKEN_BUDGET_REQUIREMENT
STATUS=
  COMPLETE_WITH_REQUIREMENT_NOT_ESTABLISHED

CORRIDOR_2=
  TOKEN_BUDGET_OWNERSHIP
STATUS=
  NOT_REQUIRED

CORRIDOR_3=
  HISTORY_WINDOW_JUSTIFICATION
STATUS=
  COMPLETE_WITH_CHANGE_REQUIREMENT_NOT_ESTABLISHED

CORRIDOR_4=
  BUDGET_AND_WINDOW_INTERACTION
STATUS=
  NOT_REQUIRED

CORRIDOR_5=
  CONTEXT_BUDGET_VALIDATION
STATUS=
  NOT_REQUIRED_WITH_NO_NEW_BUDGET_OR_WINDOW_BEHAVIOR_AUTHORIZED

PHASE_2_RESULT=
  COMPLETE_WITH_NO_CONTEXT_BUDGET_OR_HISTORY_WINDOW_CHANGE_REQUIREMENT_ESTABLISHED

RATIONALE=
  Repository evidence did not establish a requirement for repository-controlled
  token budgeting.

  The current twenty-turn production retrieval window is an observed bounded
  implementation parameter whose architectural optimality is not established.

  Repository evidence also did not establish that the current window is too
  small, too large, or responsible for a concrete behavioral failure.

  Absence of an established optimum does not authorize speculative window
  modification.

  Because neither a token-budget requirement nor a history-window change
  requirement was established, ownership and interaction classification do
  not require further decomposition in this phase.

  No new runtime behavior was authorized, so no new context-budget validation
  surface is required.

TOKEN_BUDGET_REQUIREMENT=
  NOT_ESTABLISHED

TOKEN_BUDGET_IMPLEMENTATION=
  NOT_AUTHORIZED

TOKEN_BUDGET_OWNERSHIP_CLASSIFICATION=
  NOT_REQUIRED

CURRENT_HISTORY_WINDOW=
  PRESERVE

HISTORY_WINDOW_CHANGE_REQUIREMENT=
  NOT_ESTABLISHED

HISTORY_WINDOW_CHANGE=
  NOT_AUTHORIZED

WINDOW_SIZE_EXPERIMENT=
  NOT_AUTHORIZED

BUDGET_AND_WINDOW_INTERACTION_REQUIREMENT=
  NOT_ESTABLISHED

BUDGET_AND_WINDOW_INTERACTION_CLASSIFICATION=
  NOT_REQUIRED

CONTEXT_BUDGET_VALIDATION=
  NOT_REQUIRED

EXISTING_RETRIEVAL_BOUND=
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

PHASE_2_STATUS=
  COMPLETE

NEXT_PHASE=
  HYBRID_AND_MODEL_CONTEXT_OPTIMIZATION

NEXT_CORRIDOR=
  HYBRID_CONTEXT_REQUIREMENT

NEXT_ACTION=
  CLASSIFY_HYBRID_CONTEXT_REQUIREMENT
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-2-context-budget-and-window-optimization-disposition\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 2 disposition scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
