#!/usr/bin/env bash
set -euo pipefail

echo "=== DETERMINE SUCCESSOR MILESTONE BOUNDARY AND PHASE/CORRIDOR RELATIONSHIP ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY INVESTIGATION-ONLY STARTING SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/determine-successor-milestone-boundary-and-phase-corridor-relationship\.sh$|^ M scripts/determine-successor-milestone-boundary-and-phase-corridor-relationship\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi
echo "INVESTIGATION_ONLY_STARTING_SURFACE_CONFIRMED"

echo
echo "=== GENERATION STABILITY SUCCESSOR EVIDENCE ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  'Deferred successor corridor:|CONVERSATION_ENGINE_GENERATION_STABILITY|separate Conversation Engine generation-stability/reliability corridor|Broader semantic-generation stability|generation-stability corridor' \
  docs scripts \
  2>/dev/null || true

echo
echo "=== SEMANTIC HISTORY / CONTEXT DEFERRED EVIDENCE ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  'semantic ranking|token-budget|token budget|hybrid context|model-runtime context|model context|prompt evolution|recovery/correlation' \
  docs/architecture \
  docs/checkpoints \
  scripts \
  2>/dev/null | head -n 700 || true

echo
echo "=== EXPLICIT SEMANTIC-HISTORY SUCCESSOR PROMOTION SEARCH ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  'NEXT_ACTION=.*SEMANTIC.*RANK|NEXT_ACTION=.*TOKEN.*BUDGET|NEXT_MILESTONE=.*SEMANTIC.*HISTORY|SUCCESSOR_MILESTONE=.*SEMANTIC.*HISTORY' \
  docs scripts \
  2>/dev/null || true

echo
echo "=== SHARED-PARENT RELATIONSHIP SEARCH ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  '(generation stability|generation-stability).*(semantic history|semantic ranking|token budget|hybrid context)|(semantic history|semantic ranking|token budget|hybrid context).*(generation stability|generation-stability)' \
  docs scripts \
  2>/dev/null || true

echo
echo "=== COUNT BOUNDED EVIDENCE ==="

generation_successor_hits="$(
  grep -RIlE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude-dir=dist \
    'Deferred successor corridor:|CONVERSATION_ENGINE_GENERATION_STABILITY|separate Conversation Engine generation-stability/reliability corridor' \
    docs scripts \
    2>/dev/null | wc -l | tr -d ' '
)"

semantic_history_promotion_hits="$(
  grep -RIlE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude-dir=dist \
    'NEXT_ACTION=.*SEMANTIC.*RANK|NEXT_ACTION=.*TOKEN.*BUDGET|NEXT_MILESTONE=.*SEMANTIC.*HISTORY|SUCCESSOR_MILESTONE=.*SEMANTIC.*HISTORY' \
    docs scripts \
    2>/dev/null | wc -l | tr -d ' '
)"

shared_parent_hits="$(
  grep -RIlE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude-dir=dist \
    '(generation stability|generation-stability).*(semantic history|semantic ranking|token budget|hybrid context)|(semantic history|semantic ranking|token budget|hybrid context).*(generation stability|generation-stability)' \
    docs scripts \
    2>/dev/null | wc -l | tr -d ' '
)"

echo "GENERATION_SUCCESSOR_EVIDENCE_FILES=$generation_successor_hits"
echo "SEMANTIC_HISTORY_PROMOTION_EVIDENCE_FILES=$semantic_history_promotion_hits"
echo "SHARED_PARENT_EVIDENCE_FILES=$shared_parent_hits"

echo
echo "=== EVIDENCE-BASED CLASSIFICATION ==="

if [[ "$generation_successor_hits" -gt 0 && \
      "$semantic_history_promotion_hits" -eq 0 && \
      "$shared_parent_hits" -eq 0 ]]; then
  echo "SUCCESSOR_RELATIONSHIP=GENERATION_STABILITY_IMMEDIATE_SUCCESSOR"
  echo "SUCCESSOR_MILESTONE_CANDIDATE=CONVERSATION_ENGINE_GENERATION_STABILITY"
  echo "SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=DEFERRED_SEPARATE_CANDIDATE"
  echo "BROADER_SHARED_PARENT_MILESTONE=NOT_ESTABLISHED"
  echo "SUCCESSOR_PHASE_MAP=NOT_YET_DISCOVERED"
  echo "SUCCESSOR_CORRIDOR_MAP=NOT_YET_DISCOVERED"
  echo "NEXT_ACTION=DISCOVER_GENERATION_STABILITY_PHASE_AND_CORRIDOR_MAP"
elif [[ "$shared_parent_hits" -gt 0 ]]; then
  echo "SUCCESSOR_RELATIONSHIP=SHARED_PARENT_REQUIRES_FURTHER_CLASSIFICATION"
  echo "SUCCESSOR_MILESTONE_CANDIDATE=NOT_YET_FINAL"
  echo "SUCCESSOR_PHASE_MAP=NOT_YET_DISCOVERED"
  echo "SUCCESSOR_CORRIDOR_MAP=NOT_YET_DISCOVERED"
  echo "NEXT_ACTION=CLASSIFY_SHARED_PARENT_CONVERSATION_ENGINE_MILESTONE_BOUNDARY"
else
  echo "SUCCESSOR_RELATIONSHIP=NOT_YET_DETERMINED"
  echo "SUCCESSOR_MILESTONE_CANDIDATE=NOT_YET_FINAL"
  echo "SUCCESSOR_PHASE_MAP=NOT_YET_DISCOVERED"
  echo "SUCCESSOR_CORRIDOR_MAP=NOT_YET_DISCOVERED"
  echo "NEXT_ACTION=INVESTIGATE_ADDITIONAL_SUCCESSOR_RELATIONSHIP_EVIDENCE"
fi

echo
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "IMPLEMENTATION_STARTED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEW_GOVERNANCE_DOCUMENT_REQUIRED=NO"
echo "DR_TIME=NO"

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/determine-successor-milestone-boundary-and-phase-corridor-relationship\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside successor-boundary investigation changed:"
  printf '%s\n' "$changed"
  exit 2
fi
echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/determine-successor-milestone-boundary-and-phase-corridor-relationship.sh
git diff --cached --check
git commit -m "Determine successor milestone boundary relationship"
git push
