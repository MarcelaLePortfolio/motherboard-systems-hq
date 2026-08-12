#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY SELECTED HISTORY CONTRACT PRESERVATION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

expected_head="b935b7a8"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches integrated optimization checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-selected-history-contract-preservation\.sh$|^ M scripts/classify-selected-history-contract-preservation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INTEGRATED_OPTIMIZATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING CLOSURE STATE ==="

grep -q 'INTEGRATED_OPTIMIZATION_BOUNDARY_CORRIDOR=' scripts/classify-integrated-optimization-boundary.sh
grep -q 'COMPLETE_WITH_NO_NEW_INTEGRATED_RUNTIME_REQUIREMENT_ESTABLISHED' scripts/classify-integrated-optimization-boundary.sh
grep -q 'NEXT_CORRIDOR=' scripts/classify-integrated-optimization-boundary.sh
grep -q 'SELECTED_HISTORY_CONTRACT_PRESERVATION' scripts/classify-integrated-optimization-boundary.sh

echo "GOVERNING_CLOSURE_STATE=CONFIRMED"

echo
echo "=== VERIFY EXISTING SELECTED HISTORY CONTRACT ==="

grep -q 'export interface MatildaSelectedHistoryTurn' server/matilda-history-selection-runtime.ts
grep -q 'selectedHistory' server/matilda-conversation-context-runtime.ts
grep -q 'conversationContext.selectedHistory' server/matilda-chat-workflow.ts

echo "SELECTED_HISTORY_RUNTIME_CONTRACT=CONFIRMED"

echo
echo "=== SELECTED HISTORY CONTRACT PRESERVATION ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

PHASE=
  OPTIMIZATION_INTEGRATION_AND_CLOSURE

CORRIDOR=
  SELECTED_HISTORY_CONTRACT_PRESERVATION

SELECTED_HISTORY_ROLE=
  CONVERSATION_HISTORY_BOUNDARY_CONSUMED_BY_SEMANTIC_GENERATION

SELECTED_HISTORY_ADMISSION_MODEL=
  AUTHORITY_ELIGIBLE_AND_CONTAMINATION_CLEAR_HISTORY

SELECTED_HISTORY_ORDERING=
  CHRONOLOGICAL

SELECTED_HISTORY_LINEAGE=
  PRESERVED

SELECTED_HISTORY_METADATA=
  PRESERVED

SELECTED_HISTORY_INPUT_IMMUTABILITY=
  PRESERVED

SEMANTIC_RANKING_CHANGE=
  NONE

TOKEN_BUDGET_CHANGE=
  NONE

HISTORY_WINDOW_CHANGE=
  NONE

HYBRID_CONTEXT_CHANGE=
  NONE

MODEL_RUNTIME_CONTEXT_CHANGE=
  NONE

SELECTED_HISTORY_CONTRACT_CHANGE_REQUIREMENT=
  NOT_ESTABLISHED

SELECTED_HISTORY_CONTRACT=
  PRESERVE

CLASSIFICATION=
  EXISTING_SELECTED_HISTORY_CONTRACT_REMAINS_VALID_AND_UNCHANGED

RATIONALE=
  The optimization investigation did not establish any requirement that
  changes selectedHistory admission, ordering, lineage, metadata, or workflow
  consumption.

  Comparative ranking was not established as required.

  Token-budget and history-window changes were not established as required.

  Hybrid context coordination and model-runtime context changes were not
  established as required.

  Therefore selectedHistory remains the existing bounded conversation-history
  contract consumed by semantic generation.

AUTHORITY_EVALUATION=
  PRESERVE

CONTAMINATION_EVALUATION=
  PRESERVE

CHRONOLOGY=
  PRESERVE

LINEAGE=
  PRESERVE

METADATA=
  PRESERVE

INPUT_IMMUTABILITY=
  PRESERVE

CONVERSATION_CONTEXT_RUNTIME=
  PRESERVE

OLLAMA_SELECTED_HISTORY_CONSUMPTION=
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

SELECTED_HISTORY_CONTRACT_PRESERVATION_CORRIDOR=
  COMPLETE

NEXT_CORRIDOR=
  ONE_OLLAMA_INVOCATION_PRESERVATION

NEXT_ACTION=
  CLASSIFY_ONE_OLLAMA_INVOCATION_PRESERVATION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-selected-history-contract-preservation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside selectedHistory preservation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
