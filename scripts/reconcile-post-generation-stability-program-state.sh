#!/usr/bin/env bash
set -euo pipefail

echo "=== RECONCILE POST-GENERATION-STABILITY PROGRAM STATE ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY GENERATION-STABILITY CLOSURE CHECKPOINT ==="
expected_head="d757ab0a"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches generation-stability closure checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-post-generation-stability-program-state\.sh$|^ M scripts/reconcile-post-generation-stability-program-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "GENERATION_STABILITY_CLOSURE_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CLOSED MILESTONE STATE ==="

grep -nE \
  'MILESTONE_STATUS=|COMPLETE|GENERATION_STABILITY_MILESTONE=|CLOSED|UNRESOLVED_PRODUCTION_CONDITION=|GENERATION_INSTABILITY_REMAINS|NEXT_ACTION=|RECONCILE_POST_GENERATION_STABILITY_PROGRAM_STATE' \
  scripts/close-conversation-engine-generation-stability-milestone.sh

echo "CLOSED_MILESTONE_STATE=CONFIRMED"

echo
echo "=== INVENTORY PROGRAM-LEVEL GOVERNANCE AND ARCHITECTURE SURFACES ==="

find docs -maxdepth 3 -type f \
  \( \
    -iname '*roadmap*' -o \
    -iname '*timeline*' -o \
    -iname '*milestone*' -o \
    -iname '*program*' -o \
    -iname '*architecture*' -o \
    -iname '*evidence*ledger*' \
  \) |
  sort

echo
echo "=== INVENTORY RECENT CLOSURE / NEXT-STATE SIGNALS ==="

grep -RniE \
  'NEXT_MILESTONE|NEXT CANONICAL MILESTONE|NEXT_CANONICAL_MILESTONE|DEFERRED|ACTIVE MILESTONE|ACTIVE_MILESTONE|CURRENT MILESTONE|CURRENT_MILESTONE' \
  docs scripts \
  --exclude='reconcile-post-generation-stability-program-state.sh' \
  | tail -n 200 || true

echo
echo "=== POST-MILESTONE RECONCILIATION CLASSIFICATION ==="

cat <<'MAP'
PROGRAM=
  MATILDA_CONVERSATION_ENGINE

JUST_CLOSED_MILESTONE=
  CONVERSATION_ENGINE_GENERATION_STABILITY

JUST_CLOSED_MILESTONE_STATUS=
  COMPLETE

CLOSURE_COMMIT=
  d757ab0a

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

KNOWN_DEFERRED_CONDITION=
  PRODUCTION_GENERATION_INSTABILITY_REMAINS

KNOWN_DEFERRED_CONDITION_DISPOSITION=
  EXPLICIT_PRODUCTION_POLICY_CONCERN

NEXT_MILESTONE=
  NOT_YET_CLASSIFIED

RECONCILIATION_OBJECTIVE=
  Inspect repository-supported program, roadmap, architecture, milestone, and
  deferred-work evidence to determine the next canonical milestone without
  inventing scope or reviving deferred work automatically.

RECONCILIATION_MODE=
  COLLABORATION_ONLY

IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_CHANGE=
  NONE

NEXT_ACTION=
  REVIEW_REPOSITORY_EVIDENCE_AND_CLASSIFY_NEXT_CANONICAL_MILESTONE
MAP

echo
echo "=== VERIFY RECONCILIATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-post-generation-stability-program-state\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside reconciliation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "RECONCILIATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/reconcile-post-generation-stability-program-state.sh
git diff --cached --check
git commit -m "Reconcile post-generation-stability program state"
git push
