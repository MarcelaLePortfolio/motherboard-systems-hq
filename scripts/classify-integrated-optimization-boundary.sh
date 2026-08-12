#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY INTEGRATED OPTIMIZATION BOUNDARY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="28799c13"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Phase 3 disposition checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-integrated-optimization-boundary\.sh$|^ M scripts/classify-integrated-optimization-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "PHASE_3_DISPOSITION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY PRIOR PHASE DISPOSITIONS ==="

grep -q 'PHASE_1_STATUS=' scripts/classify-phase-1-semantic-selection-optimization-disposition.sh
grep -q 'COMPLETE' scripts/classify-phase-1-semantic-selection-optimization-disposition.sh

grep -q 'PHASE_2_STATUS=' scripts/classify-phase-2-context-budget-and-window-optimization-disposition.sh
grep -q 'COMPLETE' scripts/classify-phase-2-context-budget-and-window-optimization-disposition.sh

grep -q 'PHASE_3_STATUS=' scripts/classify-phase-3-hybrid-and-model-context-optimization-disposition.sh
grep -q 'COMPLETE' scripts/classify-phase-3-hybrid-and-model-context-optimization-disposition.sh

echo "PRIOR_PHASE_DISPOSITIONS=CONFIRMED"

echo
echo "=== INTEGRATED OPTIMIZATION BOUNDARY ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

PHASE=
  OPTIMIZATION_INTEGRATION_AND_CLOSURE

CORRIDOR=
  INTEGRATED_OPTIMIZATION_BOUNDARY

PHASE_1_SEMANTIC_SELECTION_RESULT=
  COMPLETE_WITH_NO_SEMANTIC_RANKING_REQUIREMENT_ESTABLISHED

PHASE_2_CONTEXT_BUDGET_AND_WINDOW_RESULT=
  COMPLETE_WITH_NO_CONTEXT_BUDGET_OR_HISTORY_WINDOW_CHANGE_REQUIREMENT_ESTABLISHED

PHASE_3_HYBRID_AND_MODEL_CONTEXT_RESULT=
  COMPLETE_WITH_NO_HYBRID_CONTEXT_OR_MODEL_RUNTIME_CONTEXT_CHANGE_REQUIREMENT_ESTABLISHED

INTEGRATED_OPTIMIZATION_REQUIREMENT=
  NOT_ESTABLISHED

INTEGRATED_RUNTIME_CHANGE_REQUIREMENT=
  NOT_ESTABLISHED

INTEGRATED_BOUNDARY_CLASSIFICATION=
  EXISTING_SEMANTIC_HISTORY_PIPELINE_REMAINS_THE_AUTHORIZED_RUNTIME_BOUNDARY

RATIONALE=
  The completed investigation phases did not establish a requirement for
  comparative semantic ranking, repository-controlled token budgeting,
  history-window modification, hybrid cross-context coordination, or model
  runtime context reconfiguration.

  Because no individual optimization requirement was established, there is no
  evidence-supported basis for composing a new integrated optimization layer.

  The existing semantic-history preparation path therefore remains the
  authoritative runtime boundary.

  Existing authority, contamination, chronology, lineage, selectedHistory,
  project-context provenance, lifecycle-context separation, and one-Ollama-call
  invariants remain preserved.

INTEGRATED_OPTIMIZATION_IMPLEMENTATION=
  NOT_AUTHORIZED

NEW_OPTIMIZATION_LAYER=
  NOT_AUTHORIZED

SEMANTIC_RANKING=
  NOT_AUTHORIZED

TOKEN_BUDGET=
  NOT_AUTHORIZED

HISTORY_WINDOW_CHANGE=
  NOT_AUTHORIZED

HYBRID_CONTEXT_COORDINATION=
  NOT_AUTHORIZED

MODEL_RUNTIME_CONTEXT_CHANGE=
  NOT_AUTHORIZED

SELECTED_HISTORY_CONTRACT=
  PRESERVE

AUTHORITY_EVALUATION=
  PRESERVE

CONTAMINATION_EVALUATION=
  PRESERVE

CHRONOLOGY_AND_LINEAGE=
  PRESERVE

PROJECT_CONTEXT_PROVENANCE=
  PRESERVE

PRIOR_INVESTIGATION_LIFECYCLE_BOUNDARY=
  PRESERVE

ONE_OLLAMA_INVOCATION=
  PRESERVE

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

INTEGRATED_OPTIMIZATION_BOUNDARY_CORRIDOR=
  COMPLETE_WITH_NO_NEW_INTEGRATED_RUNTIME_REQUIREMENT_ESTABLISHED

NEXT_CORRIDOR=
  SELECTED_HISTORY_CONTRACT_PRESERVATION

NEXT_ACTION=
  CLASSIFY_SELECTED_HISTORY_CONTRACT_PRESERVATION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-integrated-optimization-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside integrated optimization boundary scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
