#!/usr/bin/env bash
set -euo pipefail

echo "=== CLOSE ARCHITECTURAL INVARIANT CONFIRMATION AND ENTER MILESTONE CLOSURE READINESS ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 861b65c8 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/close-architectural-invariant-confirmation-and-enter-milestone-closure-readiness\.sh$|^ M scripts/close-architectural-invariant-confirmation-and-enter-milestone-closure-readiness\.sh$' ||
  true
)"
test -z "$unexpected"

classifier="scripts/classify-architectural-invariant-confirmation.sh"
test -f "$classifier"

grep -q 'CORRIDOR_4_STATUS=' "$classifier"
grep -q '^READY_FOR_CLOSURE$' \
  <(awk '/CORRIDOR_4_STATUS=/{getline; print}' "$classifier")

grep -q 'ARCHITECTURAL_INVARIANT_CONFIRMATION=' "$classifier"
grep -q '^SATISFIED_ON_CURRENT_REPOSITORY_EVIDENCE$' \
  <(awk '/ARCHITECTURAL_INVARIANT_CONFIRMATION=/{getline; print}' "$classifier")

cat <<'MAP'
PROGRAM=
MATILDA_CONVERSATION_ENGINE

MILESTONE=
CONVERSATION_ENGINE_RELIABLE_PRODUCTION_COLLABORATION

PHASE_3=
PRODUCTION_RELIABILITY_VALIDATION_AND_MILESTONE_CLOSURE

CORRIDOR_4=
ARCHITECTURAL_INVARIANT_CONFIRMATION

CORRIDOR_4_RESULT=
ARCHITECTURAL_INVARIANTS_CONFIRMED_PRESERVED_ON_CURRENT_REPOSITORY_EVIDENCE

CORRIDOR_4_STATUS=
CLOSED

DR_CHECKPOINT=
20260816_210935

DR_PROTECTS_CORRIDOR_4_CLASSIFICATION=
YES

ACTIVE_CORRIDOR=
MILESTONE_CLOSURE_READINESS

CORRIDOR_5_PURPOSE=
RECONCILE_ALL_PHASE_EVIDENCE_AND_CLASSIFY_THE_MILESTONE_AS_READY_OR_NOT_READY_FOR_FINAL_CLOSURE

NEW_PRODUCTION_CHANGE=
NONE

IMPLEMENTATION_AUTHORIZED=
NO_NEW_IMPLEMENTATION

NEXT_ACTION=
CLASSIFY_MILESTONE_CLOSURE_READINESS
MAP
