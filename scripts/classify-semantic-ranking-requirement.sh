#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY SEMANTIC RANKING REQUIREMENT ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY PHASE-MAP CHECKPOINT ==="
expected_head="6df7560b"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches semantic-history phase-map checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-semantic-ranking-requirement\.sh$|^ M scripts/classify-semantic-ranking-requirement\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "PHASE_MAP_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY GOVERNING CORRIDOR ==="

grep -nE \
  'CURRENT_PHASE=|PHASE_1_SEMANTIC_SELECTION_OPTIMIZATION|CURRENT_CORRIDOR=|SEMANTIC_RANKING_REQUIREMENT|NEXT_ACTION=|CLASSIFY_SEMANTIC_RANKING_REQUIREMENT|SEMANTIC_RANKING_REQUIRED=|NOT_YET_DETERMINED' \
  scripts/discover-semantic-history-context-optimization-phase-and-corridor-map.sh

echo "GOVERNING_CORRIDOR=CONFIRMED"

echo
echo "=== VERIFY EXISTING SELECTION MODEL ==="

grep -nE \
  'admission|authority|contamination|selectedHistory|ranking|relevance scoring|comparative ranking|chronological|retrieval window' \
  docs/architecture/SEMANTIC_HISTORY_INVENTORY.md \
  docs/architecture/SEMANTIC_HISTORY_SELECTION_OBJECTIVES.md \
  docs/architecture/SEMANTIC_HISTORY_BEHAVIORAL_VALIDATION.md \
  | head -320 || true

echo
echo "=== SEARCH FOR EVIDENCE THAT RANKING IS REQUIRED ==="

grep -RniE \
  'ranking is required|semantic ranking is required|comparative ranking is required|must rank|must prioritize admitted history|relevance ranking required|ranking requirement' \
  docs scripts \
  --exclude='classify-semantic-ranking-requirement.sh' \
  | head -240 || true

echo
echo "=== SEARCH FOR EVIDENCE OF CURRENT RANKING FAILURE ==="

grep -RniE \
  'selectedHistory.*irrelevant|irrelevant.*selectedHistory|history.*crowd|history.*overflow|history.*token|history.*dilut|history.*noise|relevant history.*omitted|older relevant|ranking failure|selection failure' \
  docs scripts \
  --exclude='classify-semantic-ranking-requirement.sh' \
  | head -240 || true

echo
echo "=== SEMANTIC RANKING REQUIREMENT CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=
  SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION

PHASE=
  SEMANTIC_SELECTION_OPTIMIZATION

CORRIDOR=
  SEMANTIC_RANKING_REQUIREMENT

CURRENT_SELECTION_BEHAVIOR=
  AUTHORITY_AND_CONTAMINATION_ADMISSION
  CHRONOLOGICAL_PRESERVATION
  NO_COMPARATIVE_SEMANTIC_RANKING

REPOSITORY_EVIDENCE_OF_EXISTING_RANKING=
  NONE

REPOSITORY_EVIDENCE_THAT_RANKING_IS_ARCHITECTURALLY_REQUIRED=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_OF_A_CONCRETE_FAILURE_REQUIRING_RANKING=
  NOT_ESTABLISHED

REPOSITORY_EVIDENCE_THAT_CURRENT_HISTORY_SELECTION_IS_OPTIMAL=
  NOT_ESTABLISHED

SEMANTIC_RANKING_REQUIREMENT=
  NOT_ESTABLISHED

CLASSIFICATION=
  DO_NOT_IMPLEMENT_WITHOUT_CONTRADICTORY_BEHAVIORAL_OR_ARCHITECTURAL_EVIDENCE

RATIONALE=
  The active history-selection pipeline already enforces authority eligibility,
  contamination exclusion, bounded retrieval, chronology preservation, and a
  selectedHistory boundary.

  Existing architecture documents explicitly establish that comparative
  semantic ranking is absent.

  Absence alone does not establish a missing capability.

  Repository evidence does not currently establish a concrete behavioral
  failure that specifically requires comparative semantic ranking as the
  remedy.

  Repository evidence also does not establish that ranking is an architectural
  requirement independent of an observed failure.

  Therefore semantic ranking must not be promoted into implementation merely
  because it was previously deferred as a question.

FALSIFICATION_CONDITION=
  Reopen this requirement only if repository-supported evidence demonstrates
  that authority-and-contamination-admitted history cannot satisfy the
  conversation-history preparation objective without comparative semantic
  preference or ranking.

SEMANTIC_RANKING_IMPLEMENTATION=
  NOT_AUTHORIZED

SEMANTIC_RANKING_OWNERSHIP_CLASSIFICATION_REQUIRED=
  NO_WHILE_REQUIREMENT_REMAINS_UNESTABLISHED

RANKING_INPUT_AND_OUTPUT_BOUNDARY_CLASSIFICATION_REQUIRED=
  NO_WHILE_REQUIREMENT_REMAINS_UNESTABLISHED

EXISTING_HISTORY_PREPARATION=
  PRESERVE

AUTHORITY_EVALUATION=
  PRESERVE

CONTAMINATION_EVALUATION=
  PRESERVE

SELECTED_HISTORY=
  PRESERVE

CHRONOLOGY=
  PRESERVE

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

SEMANTIC_RANKING_REQUIREMENT_CORRIDOR=
  COMPLETE_WITH_REQUIREMENT_NOT_ESTABLISHED

NEXT_ACTION=
  CLASSIFY_PHASE_1_SEMANTIC_SELECTION_OPTIMIZATION_DISPOSITION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-semantic-ranking-requirement\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside semantic-ranking requirement scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
