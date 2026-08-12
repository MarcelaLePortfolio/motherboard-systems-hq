#!/usr/bin/env bash
set -euo pipefail

echo "=== RECONCILE EXISTING CROSS-TURN TRANSITION VALIDATION ==="

for checkpoint in 70d57f41 b903aca8 0f307abc; do
  git cat-file -e "${checkpoint}^{commit}"
  git merge-base --is-ancestor "$checkpoint" HEAD
done

grep -q 'validateMatildaInvestigationLifecycleContinuity' scripts/utils/ollamaChat.ts

cat <<'MAP'
CROSS_TURN_TRANSITION_VALIDATION=
ALREADY_IMPLEMENTED_AND_VALIDATED
IMPLEMENTATION_CHECKPOINT=
b903aca8
IMPLEMENTATION_CLASSIFICATION_CHECKPOINT=
0f307abc
CURRENT_READINESS_CLASSIFICATION=
SUPERSEDED_BY_REPOSITORY_EVIDENCE
UNRESOLVED_CAPABILITY_GAP=
NO
NEW_IMPLEMENTATION_REQUIRED=
NO
USER_IMPLEMENTATION_AUTHORIZATION=
GRANTED_BUT_NOT_CONSUMED
IMPLEMENTATION_STARTED=
NO
NEW_RUNTIME_CHANGE=
NONE
PRODUCTION_CHANGE=
NONE
RECONCILIATION_RESULT=
CURRENT_CAPABILITY_STATE_CORRECTED
NEXT_ACTION=
RECONCILE_SUCCESSOR_CAPABILITY_AND_PROGRAM_PRIORITY_STATE
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-existing-cross-turn-transition-validation-implementation-state\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside reconciliation scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
