#!/usr/bin/env bash
set -euo pipefail

echo "=== STOP FOR CORRIDOR 2 DR CHECKPOINT ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor ec545e23 HEAD
test -z "$(git status --porcelain)"

classification="scripts/classify-production-failure-baseline-against-current-state.sh"
test -f "$classification"

grep -q 'CORRIDOR_2_STATUS=' "$classification"
grep -q '^READY_FOR_CLOSURE$' \
  <(awk '/CORRIDOR_2_STATUS=/{getline; print}' "$classification")

grep -q 'DR_REQUIRED_BEFORE_NEXT_CORRIDOR=' "$classification"
grep -q '^YES$' \
  <(awk '/DR_REQUIRED_BEFORE_NEXT_CORRIDOR=/{getline; print}' "$classification")

cat <<'MAP'
MILESTONE=
CONVERSATION_ENGINE_RELIABLE_PRODUCTION_COLLABORATION

CORRIDOR_2=
PRODUCTION_FAILURE_BASELINE

CORRIDOR_2_CLASSIFICATION=
COMPLETE

CORRIDOR_2_STATUS=
CLOSED_PENDING_DR_CHECKPOINT

CLOSURE_COMMIT=
ec545e23

PRE_REMEDY_FAILURE_BASELINE=
PRESERVED

POST_REMEDY_COMPARISON=
VALIDATED_SUCCESS_ON_TESTED_SURFACE

PRODUCTION_CHANGE_THIS_STEP=
NONE

NEXT_ACTION=
RUN_DR_AND_RETURN_DR_CHECKPOINT_BEFORE_ENTERING_CORRIDOR_3
MAP
