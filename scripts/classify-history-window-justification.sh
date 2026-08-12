#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY HISTORY WINDOW JUSTIFICATION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

expected_head="4dd59f01"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches token-budget requirement checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-history-window-justification\.sh$|^ M scripts/classify-history-window-justification\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "TOKEN_BUDGET_REQUIREMENT_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING PHASE STATE ==="

grep -nE \
  'PHASE=|CONTEXT_BUDGET_AND_WINDOW_OPTIMIZATION|TOKEN_BUDGET_REQUIREMENT=|NOT_ESTABLISHED|HISTORY_WINDOW_JUSTIFICATION_REMAINS_REQUIRED=|YES|NEXT_CORRIDOR=|HISTORY_WINDOW_JUSTIFICATION|NEXT_ACTION=|CLASSIFY_HISTORY_WINDOW_JUSTIFICATION' \
  scripts/classify-token-budget-requirement.sh

echo "GOVERNING_PHASE_STATE=CONFIRMED"

echo
echo "=== VERIFY CURRENT RETRIEVAL IMPLEMENTATION ==="

grep -RniE \
  'listMatildaConversationTurns|limit *= *20|limit: *20|20 turns|retrieval window|bounded chronological|selectedHistory' \
  server \
  db \
  scripts \
  docs/architecture/SEMANTIC_HISTORY_*.md \
  --include='*.ts' \
  --include='*.md' \
  --include='*.sh' \
  2>/dev/null | head -320 || true

echo
echo "=== SEARCH FOR ARCHITECTURAL JUSTIFICATION OF CURRENT WINDOW ==="

grep -RniE \
  '20[- ]turn.*because|20[- ]turn.*rationale|twenty[- ]turn.*because|twenty[- ]turn.*rationale|history window.*rationale|retrieval window.*rationale|window size.*rationale|limit.*20.*because|why.*20 turns' \
  docs \
  server \
  db \
  scripts \
  2>/dev/null | head -260 || true

echo
echo "=== SEARCH FOR CONCRETE WINDOW-SIZE FAILURE EVIDENCE ==="

grep -RniE \
  '20[- ]turn.*fail|history window.*fail|retrieval window.*fail|older relevant.*omitted|relevant history.*outside|history.*missing.*limit|conversation history.*truncat|window.*too small|window.*too large|history.*crowd|history.*noise' \
  docs \
  server \
  db \
  scripts \
  --exclude='classify-history-window-justification.sh' \
  2>/dev/null | head -260 || true

echo
echo "=== HISTORY WINDOW JUSTIFICATION CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

PHASE=
  CONTEXT_BUDGET_AND_WINDOW_OPTIMIZATION

CORRIDOR=
  HISTORY_WINDOW_JUSTIFICATION

CURRENT_HISTORY_WINDOW=
  BOUNDED_RECENT_CONVERSATION_HISTORY

CURRENT_PRODUCTION_WINDOW=
  20_TURNS

CURRENT_WINDOW_FUNCTION=
  BOUND_UPSTREAM_CONVERSATION_HISTORY_RETRIEVAL_BEFORE_AUTHORITY_CONTAMINATION_AND_SELECTION_PROCESSING

CURRENT_WINDOW_ARCHITECTURAL_RATIONALE=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_THAT_20_TURNS_IS_OPTIMAL=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_THAT_20_TURNS_IS_TOO_SMALL=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_THAT_20_TURNS_IS_TOO_LARGE=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_OF_CONCRETE_WINDOW_SIZE_FAILURE=
  NOT_ESTABLISHED

HISTORY_WINDOW_CHANGE_REQUIREMENT=
  NOT_ESTABLISHED

CLASSIFICATION=
  PRESERVE_CURRENT_BOUNDED_WINDOW_UNTIL_CONTRADICTORY_BEHAVIORAL_OR_ARCHITECTURAL_EVIDENCE_EXISTS

RATIONALE=
  The repository currently bounds conversation-history retrieval before
  authority evaluation, contamination evaluation, and selectedHistory
  preparation.

  The production path has been observed requesting twenty turns.

  Repository investigation has not established why twenty is the optimal
  value.

  Lack of a documented optimum does not itself establish that the current
  value is incorrect or that runtime behavior should change.

  No repository-supported behavioral failure has been established that is
  specifically attributable to the history-window size.

  Therefore the current bounded window should be preserved rather than
  changed speculatively.

FALSIFICATION_CONDITION=
  Reopen the history-window requirement if repository-supported evidence
  demonstrates that relevant eligible conversation history is systematically
  excluded by the current bound, or that the current bound introduces
  measurable semantic degradation, context-capacity failure, or unnecessary
  prompt pressure.

CURRENT_HISTORY_WINDOW=
  PRESERVE

HISTORY_WINDOW_CHANGE=
  NOT_AUTHORIZED

WINDOW_SIZE_EXPERIMENT=
  NOT_AUTHORIZED_BY_THIS_CLASSIFICATION

TOKEN_BUDGET_REQUIREMENT=
  NOT_ESTABLISHED

TOKEN_BUDGET_IMPLEMENTATION=
  NOT_AUTHORIZED

BUDGET_AND_WINDOW_INTERACTION_REQUIREMENT=
  NOT_ESTABLISHED

BUDGET_AND_WINDOW_INTERACTION_CLASSIFICATION_REQUIRED=
  NO_WITH_BOTH_REQUIREMENTS_UNESTABLISHED

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

HISTORY_WINDOW_JUSTIFICATION_CORRIDOR=
  COMPLETE_WITH_CHANGE_REQUIREMENT_NOT_ESTABLISHED

NEXT_ACTION=
  CLASSIFY_PHASE_2_CONTEXT_BUDGET_AND_WINDOW_OPTIMIZATION_DISPOSITION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-history-window-justification\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside history-window justification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
