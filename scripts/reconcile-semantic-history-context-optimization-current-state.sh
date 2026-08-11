#!/usr/bin/env bash
set -euo pipefail

echo "=== RECONCILE SEMANTIC HISTORY CONTEXT OPTIMIZATION CURRENT STATE ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY MILESTONE CLASSIFICATION CHECKPOINT ==="
expected_head="b785e4f3"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Semantic History milestone classification checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-semantic-history-context-optimization-current-state\.sh$|^ M scripts/reconcile-semantic-history-context-optimization-current-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "MILESTONE_CLASSIFICATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING MILESTONE CLASSIFICATION ==="

grep -nE \
  'NEXT_CANONICAL_MILESTONE=|SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION|NEXT_MILESTONE_STATUS=|CLASSIFIED_NOT_STARTED|IMPLEMENTATION_AUTHORIZED=|IMPLEMENTATION_STARTED=|NEXT_ACTION=|RECONCILE_SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION_CURRENT_STATE' \
  scripts/classify-post-generation-stability-next-canonical-milestone.sh

echo "GOVERNING_MILESTONE_CLASSIFICATION=CONFIRMED"

echo
echo "=== VERIFY SEMANTIC HISTORY ARCHITECTURE DOCUMENTS ==="

docs=(
  docs/architecture/SEMANTIC_HISTORY_INVENTORY.md
  docs/architecture/SEMANTIC_HISTORY_SELECTION_OBJECTIVES.md
  docs/architecture/SEMANTIC_HISTORY_BEHAVIORAL_VALIDATION.md
  docs/architecture/SEMANTIC_HISTORY_REPOSITORY_READINESS.md
)

for file in "${docs[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "STOP: expected architecture document missing: $file"
    exit 2
  fi
  echo "FOUND=$file"
done

echo "SEMANTIC_HISTORY_ARCHITECTURE_DOCUMENTS=CONFIRMED"

echo
echo "=== INSPECT CURRENT HISTORY RUNTIME SURFACE ==="

grep -RniE \
  'selectedHistory|evaluatedInterpretations|contaminationEvaluations|listMatildaConversationTurns|Conversation Context Runtime|conversationContext|history' \
  scripts/utils \
  scripts \
  --include='*.ts' \
  2>/dev/null | head -320 || true

echo
echo "=== INSPECT EXISTING SEMANTIC HISTORY FINDINGS ==="

grep -RniE \
  'ranking|token budget|token budgeting|retrieval|bounded|chronological|authority|contamination|selectedHistory|hybrid context|model context|20-turn|deferred|not implemented|does not implement|no repository evidence' \
  docs/architecture/SEMANTIC_HISTORY_*.md \
  2>/dev/null | head -360 || true

echo
echo "=== CURRENT STATE RECONCILIATION ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

MILESTONE_STATUS=
  ACTIVE_RECONCILIATION

CURRENT_IMPLEMENTED_FOUNDATION=
  PROJECT_AND_CONVERSATION_SCOPED_HISTORY_RETRIEVAL
  BOUNDED_CHRONOLOGICAL_RETRIEVAL
  AUTHORITY_EVALUATION
  CONTAMINATION_EVALUATION
  ADMISSION_BASED_SELECTION
  SELECTED_HISTORY
  CHRONOLOGY_PRESERVATION
  LINEAGE_AND_METADATA_PRESERVATION
  INPUT_IMMUTABILITY
  CONVERSATION_CONTEXT_RUNTIME
  OLLAMA_SELECTED_HISTORY_CONSUMPTION

CURRENT_RETRIEVAL_BOUNDARY=
  BOUNDED_EXISTING_HISTORY_WINDOW

CURRENT_SELECTION_MODEL=
  ADMISSION_BASED
  NOT_COMPARATIVE_SEMANTIC_RANKING

CURRENT_SEMANTIC_RANKING=
  NOT_IMPLEMENTED

CURRENT_REPOSITORY_CONTROLLED_POST_RETRIEVAL_TOKEN_BUDGET=
  NOT_ESTABLISHED

CURRENT_HYBRID_CONTEXT_OPTIMIZATION=
  NOT_ESTABLISHED

CURRENT_MODEL_RUNTIME_CONTEXT_OPTIMIZATION=
  NOT_ESTABLISHED

CURRENT_BOUNDED_HISTORY_WINDOW_OPTIMIZATION=
  NOT_ESTABLISHED_BEYOND_EXISTING_RETRIEVAL_BOUND

ARCHITECTURE_INVESTIGATION_FOUNDATION=
  SEMANTIC_HISTORY_INVENTORY
  SEMANTIC_HISTORY_SELECTION_OBJECTIVES
  SEMANTIC_HISTORY_BEHAVIORAL_VALIDATION
  SEMANTIC_HISTORY_REPOSITORY_READINESS

RECONCILIATION_RESULT=
  EXISTING_HISTORY_PREPARATION_PIPELINE_IS_IMPLEMENTED
  OPTIMIZATION_RESPONSIBILITIES_REMAIN_SEPARATE_AND_REQUIRE_SCOPE_CLASSIFICATION

SCOPE_MUST_DISTINGUISH=
  EXISTING_HISTORY_PREPARATION
  SEMANTIC_RANKING
  TOKEN_BUDGET_BEHAVIOR
  HYBRID_CONTEXT
  MODEL_RUNTIME_CONTEXT
  HISTORY_WINDOW_OPTIMIZATION

PRODUCTION_GENERATION_POLICY_CONCERN=
  SEPARATE_AND_DEFERRED

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

CURRENT_STATE_RECONCILIATION=
  COMPLETE

NEXT_ACTION=
  CLASSIFY_SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION_SCOPE
MAP

echo
echo "=== VERIFY RECONCILIATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-semantic-history-context-optimization-current-state\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside current-state reconciliation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "RECONCILIATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
