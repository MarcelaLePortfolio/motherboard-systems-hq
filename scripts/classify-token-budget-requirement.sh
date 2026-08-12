#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY TOKEN BUDGET REQUIREMENT ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

expected_head="904d1d18"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Phase 1 disposition checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-token-budget-requirement\.sh$|^ M scripts/classify-token-budget-requirement\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "PHASE_1_DISPOSITION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING PHASE TRANSITION ==="

grep -nE \
  'PHASE_1_STATUS=|COMPLETE|NEXT_PHASE=|CONTEXT_BUDGET_AND_WINDOW_OPTIMIZATION|NEXT_CORRIDOR=|TOKEN_BUDGET_REQUIREMENT|NEXT_ACTION=|CLASSIFY_TOKEN_BUDGET_REQUIREMENT' \
  scripts/classify-phase-1-semantic-selection-optimization-disposition.sh

echo "GOVERNING_PHASE_TRANSITION=CONFIRMED"

echo
echo "=== VERIFY EXISTING TOKEN-BUDGET FINDINGS ==="

grep -nE \
  'Token Budget Behavior|token budget|token budgeting|max-token|retrieval window|twenty turns|20 turns|model context|selectedHistory' \
  docs/architecture/SEMANTIC_HISTORY_SELECTION_OBJECTIVES.md \
  docs/architecture/SEMANTIC_HISTORY_BEHAVIORAL_VALIDATION.md \
  docs/architecture/SEMANTIC_HISTORY_REPOSITORY_READINESS.md \
  | head -320 || true

echo
echo "=== SEARCH FOR CONCRETE TOKEN-BUDGET FAILURE EVIDENCE ==="

grep -RniE \
  'token budget.*failure|context window.*overflow|context length|too many tokens|token overflow|prompt too large|selectedHistory.*too large|history.*too large|history.*truncat|context.*truncat|20 turns.*failure|twenty turns.*failure' \
  docs scripts \
  --exclude='classify-token-budget-requirement.sh' \
  | head -240 || true

echo
echo "=== TOKEN BUDGET REQUIREMENT CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

PHASE=
  CONTEXT_BUDGET_AND_WINDOW_OPTIMIZATION

CORRIDOR=
  TOKEN_BUDGET_REQUIREMENT

CURRENT_HISTORY_BUDGETING_BEHAVIOR=
  RETRIEVAL_IS_BOUNDED_BEFORE_SEMANTIC_SELECTION
  NO_ADDITIONAL_REPOSITORY_CONTROLLED_POST_SELECTION_TOKEN_BUDGET_IDENTIFIED
  SELECTED_HISTORY_PASSES_DIRECTLY_TO_CONVERSATION_WORKFLOW

CURRENT_RETRIEVAL_WINDOW=
  BOUNDED_RECENT_HISTORY
  CURRENT_PRODUCTION_USAGE_OBSERVED_AS_20_TURNS

REPOSITORY_EVIDENCE_THAT_POST_SELECTION_TOKEN_BUDGET_IS_REQUIRED=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_OF_CONCRETE_TOKEN_BUDGET_FAILURE=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_THAT_CURRENT_RETRIEVAL_WINDOW_IS_OPTIMAL=
  NOT_ESTABLISHED

TOKEN_BUDGET_REQUIREMENT=
  NOT_ESTABLISHED

CLASSIFICATION=
  DO_NOT_IMPLEMENT_REPOSITORY_CONTROLLED_TOKEN_BUDGET_WITHOUT_CONTRADICTORY_BEHAVIORAL_OR_ARCHITECTURAL_EVIDENCE

RATIONALE=
  The repository already bounds conversation-history retrieval before semantic
  preparation.

  Existing architecture evidence does not establish an additional
  repository-controlled token-budget calculation or post-selection trimming
  stage.

  Absence of such a stage does not itself establish a missing capability.

  Repository evidence does not currently establish a concrete context-overflow,
  token-overflow, prompt-size, or truncation failure that specifically requires
  a repository-controlled token-budget mechanism.

  The current retrieval window also remains an observed implementation
  parameter rather than an architecturally justified optimum.

FALSIFICATION_CONDITION=
  Reopen the token-budget requirement if repository-supported evidence
  demonstrates that the existing bounded retrieval window cannot reliably
  satisfy conversation-history preparation because of model-context,
  prompt-size, token-capacity, or deterministic truncation constraints.

TOKEN_BUDGET_IMPLEMENTATION=
  NOT_AUTHORIZED

TOKEN_BUDGET_OWNERSHIP_CLASSIFICATION_REQUIRED=
  NO_WHILE_REQUIREMENT_REMAINS_UNESTABLISHED

HISTORY_WINDOW_JUSTIFICATION_REMAINS_REQUIRED=
  YES

BUDGET_AND_WINDOW_INTERACTION_CLASSIFICATION=
  DEFER_UNTIL_HISTORY_WINDOW_REQUIREMENT_IS_CLASSIFIED

EXISTING_RETRIEVAL_BOUND=
  PRESERVE

SELECTED_HISTORY=
  PRESERVE

AUTHORITY_EVALUATION=
  PRESERVE

CONTAMINATION_EVALUATION=
  PRESERVE

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

IMPLEMENTATION_AUTHORIZED=
  NO

IMPLEMENTATION_STARTED=
  NO

PRODUCTION_CHANGE=
  NONE

TOKEN_BUDGET_REQUIREMENT_CORRIDOR=
  COMPLETE_WITH_REQUIREMENT_NOT_ESTABLISHED

NEXT_CORRIDOR=
  HISTORY_WINDOW_JUSTIFICATION

NEXT_ACTION=
  CLASSIFY_HISTORY_WINDOW_JUSTIFICATION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-token-budget-requirement\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside token-budget requirement scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
