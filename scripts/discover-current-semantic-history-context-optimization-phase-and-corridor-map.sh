#!/usr/bin/env bash
set -euo pipefail

echo "=== DISCOVER CURRENT SEMANTIC HISTORY CONTEXT OPTIMIZATION PHASE AND CORRIDOR MAP ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 68e8bae2 HEAD

scope="scripts/classify-current-semantic-history-context-optimization-scope.sh"
test -f "$scope"

echo "=== VERIFY CURRENT SCOPE CLASSIFICATION ==="
grep -q 'SCOPE_CLASSIFICATION=' "$scope"
grep -q 'COMPLETE' "$scope"
grep -q 'SEMANTIC_HISTORY_RANKING_STATUS=' "$scope"
grep -q 'TOKEN_BUDGET_STATUS=' "$scope"
grep -q 'HYBRID_CONTEXT_STATUS=' "$scope"
grep -q 'MODEL_RUNTIME_CONTEXT_STATUS=' "$scope"
grep -q 'BOUNDED_HISTORY_WINDOW_STATUS=' "$scope"
grep -q 'INVESTIGATION_REQUIRED' "$scope"
echo "CURRENT_SCOPE_CLASSIFICATION=CONFIRMED"

echo
echo "=== DISCOVER EXISTING SEMANTIC HISTORY MAP EVIDENCE ==="

grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION|semantic history.*phase|semantic history.*corridor|ranking.*corridor|token budget.*corridor|hybrid context.*corridor|model runtime context|bounded history window' \
  scripts docs/architecture \
  2>/dev/null | head -320 || true

echo
echo "=== VERIFY FIVE CURRENT INVESTIGATION RESPONSIBILITIES ==="

for marker in \
  SEMANTIC_HISTORY_RANKING \
  TOKEN_BUDGET_BEHAVIOR \
  HYBRID_CONTEXT_RELATIONSHIP \
  MODEL_RUNTIME_CONTEXT_BOUNDARY \
  BOUNDED_HISTORY_WINDOW_OPTIMIZATION
do
  grep -q "$marker" "$scope"
  echo "CONFIRMED=$marker"
done

echo
echo "=== PHASE / CORRIDOR MAP DISCOVERY ==="

cat <<'MAP'
MILESTONE=
SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

MILESTONE_STATUS=
ACTIVE

DISCOVERY_BASIS=
CURRENT_SCOPE_CLASSIFICATION
EXISTING_SEMANTIC_HISTORY_ARCHITECTURE_FOUNDATION
REQUIREMENT_AND_OWNERSHIP_BEFORE_IMPLEMENTATION

PROPOSED_PHASE_1=
OPTIMIZATION_REQUIREMENT_AND_OWNERSHIP_CLASSIFICATION

PHASE_1_CORRIDORS=
SEMANTIC_HISTORY_RANKING
TOKEN_BUDGET_BEHAVIOR
HYBRID_CONTEXT_RELATIONSHIP
MODEL_RUNTIME_CONTEXT_BOUNDARY
BOUNDED_HISTORY_WINDOW_OPTIMIZATION

PHASE_1_CORRIDOR_COUNT=
5

PHASE_1_IMPLEMENTATION_AUTHORIZED=
NO

SUCCESSOR_PHASES=
NOT_YET_ESTABLISHED

RATIONALE=
The current repository evidence establishes five distinct optimization
responsibilities, but does not yet establish that any of them require runtime
implementation.

Therefore the smallest evidence-supported phase is a five-corridor
requirement-and-ownership classification phase.

No design, implementation, ranking algorithm, token budget, retrieval change,
prompt change, or runtime-context change should be introduced until each
corridor establishes whether a capability is actually required and where it
belongs.

PRODUCTION_GENERATION_POLICY_REOPENED=
NO

SELECTED_HISTORY_CONTRACT_CHANGE=
NOT_AUTHORIZED

AUTHORITY_BOUNDARY_CHANGE=
NOT_AUTHORIZED

CONTAMINATION_BOUNDARY_CHANGE=
NOT_AUTHORIZED

PROMPT_CHANGE=
NOT_AUTHORIZED

OLLAMA_INVOCATION_COUNT_CHANGE=
NOT_AUTHORIZED

IMPLEMENTATION_AUTHORIZED=
NO

IMPLEMENTATION_STARTED=
NO

PRODUCTION_CHANGE=
NONE

PHASE_MAP_STATUS=
PHASE_1_ESTABLISHED
LATER_PHASES_NOT_YET_ESTABLISHED

NEXT_PHASE=
OPTIMIZATION_REQUIREMENT_AND_OWNERSHIP_CLASSIFICATION

NEXT_CORRIDOR=
SEMANTIC_HISTORY_RANKING

NEXT_ACTION=
CLASSIFY_SEMANTIC_HISTORY_RANKING_REQUIREMENT_AND_OWNERSHIP
MAP
