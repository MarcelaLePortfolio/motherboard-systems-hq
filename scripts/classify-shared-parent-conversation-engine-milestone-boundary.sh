#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY SHARED-PARENT CONVERSATION ENGINE MILESTONE BOUNDARY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY CLASSIFICATION-ONLY STARTING SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-shared-parent-conversation-engine-milestone-boundary\.sh$|^ M scripts/classify-shared-parent-conversation-engine-milestone-boundary\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi
echo "CLASSIFICATION_ONLY_STARTING_SURFACE_CONFIRMED"

echo
echo "=== EXCLUDE SELF-REFERENTIAL DISCOVERY ARTIFACTS ==="
EXCLUDES=(
  --exclude='determine-successor-milestone-boundary-and-phase-corridor-relationship.sh'
  --exclude='classify-post-collaboration-runtime-capability-state.sh'
  --exclude='classify-shared-parent-conversation-engine-milestone-boundary.sh'
)

echo "SELF_REFERENTIAL_DISCOVERY_ARTIFACTS=EXCLUDED"

echo
echo "=== GENERATION STABILITY SUCCESSOR EVIDENCE ==="
generation_evidence="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude-dir=dist \
    "${EXCLUDES[@]}" \
    'Deferred successor corridor:|CONVERSATION_ENGINE_GENERATION_STABILITY|separate Conversation Engine generation-stability/reliability corridor|Broader semantic-generation stability|generation-stability corridor' \
    docs scripts \
    2>/dev/null || true
)"
printf '%s\n' "$generation_evidence"

echo
echo "=== SEMANTIC-HISTORY EXPLICIT SUCCESSOR PROMOTION EVIDENCE ==="
semantic_promotion="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude-dir=dist \
    "${EXCLUDES[@]}" \
    'NEXT_ACTION=.*SEMANTIC.*RANK|NEXT_ACTION=.*TOKEN.*BUDGET|NEXT_MILESTONE=.*SEMANTIC.*HISTORY|SUCCESSOR_MILESTONE=.*SEMANTIC.*HISTORY' \
    docs scripts \
    2>/dev/null || true
)"
printf '%s\n' "$semantic_promotion"

echo
echo "=== EXPLICIT SHARED-PARENT EVIDENCE ==="
shared_parent="$(
  grep -RInE \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude-dir=dist \
    "${EXCLUDES[@]}" \
    '(generation stability|generation-stability).*(semantic history|semantic ranking|token budget|hybrid context)|(semantic history|semantic ranking|token budget|hybrid context).*(generation stability|generation-stability)' \
    docs scripts \
    2>/dev/null || true
)"
printf '%s\n' "$shared_parent"

echo
echo "=== SEMANTIC-HISTORY BOUNDARY EVIDENCE ==="
grep -nE \
  'semantic ranking|token-budget|token budget|model context|should or should not|No repository evidence|does not establish|not established|future|defer' \
  docs/architecture/SEMANTIC_HISTORY_REPOSITORY_READINESS.md \
  docs/architecture/SEMANTIC_HISTORY_SELECTION_OBJECTIVES.md \
  docs/architecture/SEMANTIC_HISTORY_BEHAVIORAL_VALIDATION.md \
  2>/dev/null || true

echo
echo "=== GENERATION-STABILITY BOUNDARY EVIDENCE ==="
grep -nE \
  'Deferred successor corridor|CONVERSATION_ENGINE_GENERATION_STABILITY|separate Conversation Engine generation-stability/reliability corridor|Broader semantic-generation stability|production sampling policy|remaining unseeded variance' \
  scripts/validate-adaptive-detail-corridor-closure.sh \
  scripts/determine-adaptive-detail-production-stability-acceptance-contract.sh \
  scripts/classify-phase-1-response-composition-state.sh \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh \
  2>/dev/null || true

echo
echo "=== CORRECTED EVIDENCE COUNTS ==="

generation_files=0
if [[ -n "$generation_evidence" ]]; then
  generation_files="$(
    printf '%s\n' "$generation_evidence" |
    cut -d: -f1 |
    sort -u |
    wc -l |
    tr -d ' '
  )"
fi

semantic_promotion_files=0
if [[ -n "$semantic_promotion" ]]; then
  semantic_promotion_files="$(
    printf '%s\n' "$semantic_promotion" |
    cut -d: -f1 |
    sort -u |
    wc -l |
    tr -d ' '
  )"
fi

shared_parent_files=0
if [[ -n "$shared_parent" ]]; then
  shared_parent_files="$(
    printf '%s\n' "$shared_parent" |
    cut -d: -f1 |
    sort -u |
    wc -l |
    tr -d ' '
  )"
fi

echo "GENERATION_SUCCESSOR_EVIDENCE_FILES=$generation_files"
echo "SEMANTIC_HISTORY_PROMOTION_EVIDENCE_FILES=$semantic_promotion_files"
echo "SHARED_PARENT_EVIDENCE_FILES=$shared_parent_files"

echo
echo "=== EVIDENCE-BASED CLASSIFICATION ==="

if [[ "$generation_files" -gt 0 && \
      "$semantic_promotion_files" -eq 0 && \
      "$shared_parent_files" -eq 0 ]]; then

  echo "SHARED_PARENT_CONVERSATION_ENGINE_MILESTONE=NOT_ESTABLISHED"
  echo "SUCCESSOR_RELATIONSHIP=GENERATION_STABILITY_IMMEDIATE_SUCCESSOR"
  echo "SUCCESSOR_MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY"
  echo "SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=SEPARATELY_DEFERRED"
  echo "SUCCESSOR_PHASE_MAP=NOT_YET_DISCOVERED"
  echo "SUCCESSOR_CORRIDOR_MAP=NOT_YET_DISCOVERED"
  echo "MILESTONE_DOCUMENTATION=NOT_YET_REQUIRED"
  echo "NEXT_ACTION=DISCOVER_GENERATION_STABILITY_PHASE_AND_CORRIDOR_MAP"

elif [[ "$shared_parent_files" -gt 0 ]]; then

  echo "SHARED_PARENT_CONVERSATION_ENGINE_MILESTONE=REPOSITORY_EVIDENCE_PRESENT"
  echo "SUCCESSOR_MILESTONE=NOT_YET_FINAL"
  echo "SUCCESSOR_PHASE_MAP=NOT_YET_DISCOVERED"
  echo "SUCCESSOR_CORRIDOR_MAP=NOT_YET_DISCOVERED"
  echo "NEXT_ACTION=INSPECT_SHARED_PARENT_EVIDENCE_BEFORE_MILESTONE_PROMOTION"

elif [[ "$semantic_promotion_files" -gt 0 ]]; then

  echo "SEMANTIC_HISTORY_SUCCESSOR_PROMOTION=REPOSITORY_EVIDENCE_PRESENT"
  echo "SUCCESSOR_MILESTONE=NOT_YET_FINAL"
  echo "SUCCESSOR_PHASE_MAP=NOT_YET_DISCOVERED"
  echo "SUCCESSOR_CORRIDOR_MAP=NOT_YET_DISCOVERED"
  echo "NEXT_ACTION=COMPARE_GENERATION_STABILITY_AND_SEMANTIC_HISTORY_SUCCESSOR_AUTHORITY"

else

  echo "SUCCESSOR_MILESTONE=NOT_YET_DETERMINED"
  echo "SUCCESSOR_PHASE_MAP=NOT_YET_DISCOVERED"
  echo "SUCCESSOR_CORRIDOR_MAP=NOT_YET_DISCOVERED"
  echo "NEXT_ACTION=INVESTIGATE_ADDITIONAL_NON_SELF_REFERENTIAL_SUCCESSOR_EVIDENCE"

fi

echo
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "IMPLEMENTATION_STARTED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "DR_TIME=NO"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-shared-parent-conversation-engine-milestone-boundary\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi
echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-shared-parent-conversation-engine-milestone-boundary.sh
git diff --cached --check
git commit -m "Classify successor milestone boundary"
git push
