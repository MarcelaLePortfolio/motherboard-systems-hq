#!/usr/bin/env bash
set -euo pipefail

echo "=== DIAGNOSE SUCCESSOR SELECTION HEAD MISMATCH ==="

expected_checkpoint="c57b8b43"
current_head="$(git rev-parse --short=8 HEAD)"

echo "EXPECTED_SUCCESSOR_RECOMMENDATION_CHECKPOINT=$expected_checkpoint"
echo "CURRENT_HEAD=$current_head"
echo "CURRENT_COMMIT=$(git log -1 --format=%s)"

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/diagnose-successor-selection-head-mismatch\.sh$|^ M scripts/diagnose-successor-selection-head-mismatch\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

if git merge-base --is-ancestor "$expected_checkpoint" HEAD 2>/dev/null; then
  echo "SUCCESSOR_RECOMMENDATION_CHECKPOINT_ANCESTOR_OF_HEAD=YES"
else
  echo "SUCCESSOR_RECOMMENDATION_CHECKPOINT_ANCESTOR_OF_HEAD=NO"
fi

echo
echo "=== COMMITS AFTER SUCCESSOR RECOMMENDATION CHECKPOINT ==="
git log --oneline --decorate "${expected_checkpoint}..HEAD"

cat <<'STATE'
USER_DECISION=
CONTINUE_GENERATION_STABILITY_WORK

SELECTED_DIRECTION_REQUESTED=
PRODUCTION_GENERATION_POLICY_AND_SEMANTIC_PRESERVATION_INVESTIGATION

SELECTION_COMMAND_RESULT=
NOT_EXECUTED_DUE_TO_HEAD_MISMATCH

SUCCESSOR_PHASE_SELECTION=
NOT_YET_RECORDED

SUCCESSOR_PHASE_STARTED=
NO

SUCCESSOR_CORRIDOR_MAP=
NOT_ESTABLISHED

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_GENERATION_POLICY_CHANGE=
NOT_AUTHORIZED

PRODUCTION_CHANGE=
NONE

NEXT_ACTION=
RECONCILE_CURRENT_HEAD_WITH_SUCCESSOR_RECOMMENDATION_BEFORE_RECORDING_USER_SELECTION
STATE

changed="$(
  git diff --name-only |
  grep -vE '^scripts/diagnose-successor-selection-head-mismatch\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside successor-selection diagnosis scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

git diff --check
