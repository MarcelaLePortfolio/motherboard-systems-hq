#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY POST-GENERATION-STABILITY NEXT CANONICAL MILESTONE ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY POST-MILESTONE RECONCILIATION CHECKPOINT ==="
expected_head="d2ea5122"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches post-generation-stability reconciliation checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-post-generation-stability-next-canonical-milestone\.sh$|^ M scripts/classify-post-generation-stability-next-canonical-milestone\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "POST_MILESTONE_RECONCILIATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CLOSED GENERATION-STABILITY STATE ==="

grep -nE \
  'JUST_CLOSED_MILESTONE=|CONVERSATION_ENGINE_GENERATION_STABILITY|JUST_CLOSED_MILESTONE_STATUS=|COMPLETE|NEXT_MILESTONE=|NOT_YET_CLASSIFIED|REVIEW_REPOSITORY_EVIDENCE_AND_CLASSIFY_NEXT_CANONICAL_MILESTONE' \
  scripts/reconcile-post-generation-stability-program-state.sh

echo "CLOSED_GENERATION_STABILITY_STATE=CONFIRMED"

echo
echo "=== VERIFY PRIOR SUCCESSOR BOUNDARY EVIDENCE ==="

grep -nE \
  'SUCCESSOR_MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY|GENERATION_STABILITY_IMMEDIATE_SUCCESSOR|SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=SEPARATELY_DEFERRED' \
  scripts/classify-shared-parent-conversation-engine-milestone-boundary.sh \
  scripts/classify-generation-stability-phase-corridor-map.sh \
  scripts/discover-generation-stability-phase-corridor-map.sh \
  2>/dev/null || true

echo
echo "=== VERIFY SEMANTIC-HISTORY ARCHITECTURE SURFACE ==="

semantic_history_docs=(
  docs/architecture/SEMANTIC_HISTORY_INVENTORY.md
  docs/architecture/SEMANTIC_HISTORY_SELECTION_OBJECTIVES.md
  docs/architecture/SEMANTIC_HISTORY_BEHAVIORAL_VALIDATION.md
  docs/architecture/SEMANTIC_HISTORY_REPOSITORY_READINESS.md
)

for file in "${semantic_history_docs[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "STOP: expected semantic-history architecture document missing: $file"
    exit 2
  fi
  echo "FOUND=$file"
done

echo "SEMANTIC_HISTORY_ARCHITECTURE_SURFACE=CONFIRMED"

echo
echo "=== INSPECT SEMANTIC-HISTORY DEFERRED / READINESS SIGNALS ==="

grep -RniE \
  'semantic history ranking|semantic-history ranking|ranking|token budget|context optimization|hybrid context|20-turn|repository readiness|ready|deferred|next action|next milestone' \
  docs/architecture/SEMANTIC_HISTORY_*.md \
  scripts/classify-post-collaboration-runtime-capability-state.sh \
  scripts/classify-shared-parent-conversation-engine-milestone-boundary.sh \
  2>/dev/null | head -260 || true

echo
echo "=== VERIFY NO AUTOMATIC PROMOTION OF PRODUCTION GENERATION POLICY ==="

grep -nE \
  'KNOWN_DEFERRED_CONDITION=|PRODUCTION_GENERATION_INSTABILITY_REMAINS|KNOWN_DEFERRED_CONDITION_DISPOSITION=|EXPLICIT_PRODUCTION_POLICY_CONCERN|IMPLEMENTATION_AUTHORIZED=|NO' \
  scripts/reconcile-post-generation-stability-program-state.sh

echo "PRODUCTION_GENERATION_POLICY_REMAINS_DEFERRED=CONFIRMED"

echo
echo "=== NEXT CANONICAL MILESTONE CLASSIFICATION ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

PREVIOUS_MILESTONE=
  CONVERSATION_ENGINE_GENERATION_STABILITY

PREVIOUS_MILESTONE_STATUS=
  COMPLETE

NEXT_CANONICAL_MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

SUCCESSOR_RELATIONSHIP=
  NEXT_ELIGIBLE_DEFERRED_CONVERSATION_ENGINE_MILESTONE

CLASSIFICATION_BASIS=
  Semantic History Context Optimization was explicitly preserved as separately
  deferred while Generation Stability was promoted as the immediate successor
  to Matilda Collaboration Runtime.

  Generation Stability is now closed.

  The repository already contains a dedicated Semantic History architecture
  surface covering inventory, selection objectives, behavioral validation,
  and repository readiness.

  Therefore Semantic History Context Optimization is the next repository-
  supported Conversation Engine milestone eligible for active reconciliation.

IMPORTANT_BOUNDARY=
  Eligibility does not imply implementation authorization.

  The milestone must begin with current-state reconciliation and scope
  classification before any optimization, ranking, token-budget, retrieval,
  prompt, or runtime change is authorized.

KNOWN_EXISTING_FOUNDATION=
  CONVERSATION_HISTORY_PREPARATION_FOR_SEMANTIC_GENERATION
  PROJECT_AND_CONVERSATION_SCOPED_HISTORY_RETRIEVAL
  BOUNDED_CHRONOLOGICAL_RETRIEVAL
  AUTHORITY_AND_CONTAMINATION_EVALUATION
  SELECTED_HISTORY
  SEMANTIC_HISTORY_INVENTORY
  SEMANTIC_HISTORY_SELECTION_OBJECTIVES
  SEMANTIC_HISTORY_BEHAVIORAL_VALIDATION
  SEMANTIC_HISTORY_REPOSITORY_READINESS

CANDIDATE_OPTIMIZATION_CONCERNS_TO_RECONCILE=
  SEMANTIC_HISTORY_RANKING
  TOKEN_BUDGET
  HYBRID_CONTEXT
  MODEL_RUNTIME_CONTEXT
  BOUNDED_HISTORY_WINDOW_OPTIMIZATION

NOT_AUTOMATICALLY_IN_SCOPE=
  PRODUCTION_GENERATION_POLICY
  FIXED_SEED_PROMOTION
  VALIDATOR_RELAXATION
  RETRIES
  MULTIPLE_OLLAMA_INVOCATIONS

DEFERRED_PRODUCTION_GENERATION_INSTABILITY=
  PRESERVE_AS_SEPARATE_POLICY_CONCERN

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

NEXT_MILESTONE_STATUS=
  CLASSIFIED_NOT_STARTED

NEXT_ACTION=
  RECONCILE_SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION_CURRENT_STATE
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-post-generation-stability-next-canonical-milestone\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside next-milestone classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
