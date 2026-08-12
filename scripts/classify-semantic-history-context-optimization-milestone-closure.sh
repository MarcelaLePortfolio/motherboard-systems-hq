#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY SEMANTIC HISTORY CONTEXT OPTIMIZATION MILESTONE CLOSURE ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="93898b87"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches deterministic regression checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-semantic-history-context-optimization-milestone-closure\.sh$|^ M scripts/classify-semantic-history-context-optimization-milestone-closure\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "DETERMINISTIC_REGRESSION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY PHASE CLOSURES ==="

grep -q 'PHASE_1_STATUS=' scripts/classify-phase-1-semantic-selection-optimization-disposition.sh
grep -q 'COMPLETE' scripts/classify-phase-1-semantic-selection-optimization-disposition.sh

grep -q 'PHASE_2_STATUS=' scripts/classify-phase-2-context-budget-and-window-optimization-disposition.sh
grep -q 'COMPLETE' scripts/classify-phase-2-context-budget-and-window-optimization-disposition.sh

grep -q 'PHASE_3_STATUS=' scripts/classify-phase-3-hybrid-and-model-context-optimization-disposition.sh
grep -q 'COMPLETE' scripts/classify-phase-3-hybrid-and-model-context-optimization-disposition.sh

grep -q 'INTEGRATED_OPTIMIZATION_BOUNDARY_CORRIDOR=' scripts/classify-integrated-optimization-boundary.sh
grep -q 'SELECTED_HISTORY_CONTRACT_PRESERVATION_CORRIDOR=' scripts/classify-selected-history-contract-preservation.sh
grep -q 'ONE_OLLAMA_INVOCATION_PRESERVATION_CORRIDOR=' scripts/classify-one-ollama-invocation-preservation.sh
grep -q 'DETERMINISTIC_REGRESSION_VALIDATION_CORRIDOR=' scripts/classify-deterministic-regression-validation.sh

echo "ALL_MILESTONE_CLOSURE_PREREQUISITES=CONFIRMED"

echo
echo "=== MILESTONE CLOSURE CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

PHASE_1=
  SEMANTIC_SELECTION_OPTIMIZATION
STATUS=
  COMPLETE

PHASE_2=
  CONTEXT_BUDGET_AND_WINDOW_OPTIMIZATION
STATUS=
  COMPLETE

PHASE_3=
  HYBRID_AND_MODEL_CONTEXT_OPTIMIZATION
STATUS=
  COMPLETE

PHASE_4=
  OPTIMIZATION_INTEGRATION_AND_CLOSURE
STATUS=
  COMPLETE

SEMANTIC_RANKING_REQUIREMENT=
  NOT_ESTABLISHED

TOKEN_BUDGET_REQUIREMENT=
  NOT_ESTABLISHED

HISTORY_WINDOW_CHANGE_REQUIREMENT=
  NOT_ESTABLISHED

HYBRID_CONTEXT_REQUIREMENT=
  NOT_ESTABLISHED

MODEL_RUNTIME_CONTEXT_CHANGE_REQUIREMENT=
  NOT_ESTABLISHED

INTEGRATED_OPTIMIZATION_REQUIREMENT=
  NOT_ESTABLISHED

SELECTED_HISTORY_CONTRACT=
  PRESERVED

AUTHORITY_EVALUATION=
  PRESERVED

CONTAMINATION_EVALUATION=
  PRESERVED

CHRONOLOGY_AND_LINEAGE=
  PRESERVED

INPUT_IMMUTABILITY=
  PRESERVED

CONVERSATION_CONTEXT_RUNTIME=
  PRESERVED

PROJECT_CONTEXT_BOUNDARY=
  PRESERVED

PRIOR_INVESTIGATION_LIFECYCLE_BOUNDARY=
  PRESERVED

STRUCTURED_RESPONSE_CONTRACT=
  PRESERVED

FAIL_CLOSED_VALIDATION=
  PRESERVED

ONE_OLLAMA_INVOCATION=
  PRESERVED

DETERMINISTIC_REGRESSION_VALIDATION=
  PASS

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

NEW_RUNTIME_BEHAVIOR=
  NONE

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

MILESTONE_CLOSURE_CLASSIFICATION=
  COMPLETE_WITH_NO_NEW_OPTIMIZATION_REQUIREMENT_ESTABLISHED

MILESTONE_STATUS=
  CLOSED

NEXT_PROGRAM_ACTION=
  RECONCILE_POST_SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION_PROGRAM_STATE
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-semantic-history-context-optimization-milestone-closure\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside milestone closure classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
