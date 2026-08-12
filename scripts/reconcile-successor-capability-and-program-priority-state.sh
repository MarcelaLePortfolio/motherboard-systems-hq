#!/usr/bin/env bash
set -euo pipefail

echo "=== RECONCILE SUCCESSOR CAPABILITY AND PROGRAM PRIORITY STATE ==="

expected_head="c2a7f9cd"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches cross-turn reconciliation checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-successor-capability-and-program-priority-state\.sh$|^ M scripts/reconcile-successor-capability-and-program-priority-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

grep -q 'CROSS_TURN_TRANSITION_VALIDATION=' \
  scripts/reconcile-existing-cross-turn-transition-validation-implementation-state.sh
grep -q 'ALREADY_IMPLEMENTED_AND_VALIDATED' \
  scripts/reconcile-existing-cross-turn-transition-validation-implementation-state.sh
grep -q 'UNRESOLVED_CAPABILITY_GAP=' \
  scripts/reconcile-existing-cross-turn-transition-validation-implementation-state.sh
grep -q '^NO$' \
  <(awk '/UNRESOLVED_CAPABILITY_GAP=/{getline; print}' \
    scripts/reconcile-existing-cross-turn-transition-validation-implementation-state.sh)

cat <<'MAP'
PROGRAM=
MATILDA_CONVERSATION_ENGINE
PROGRAM_RECONCILIATION_MILESTONE=
CONVERSATION_ENGINE_PROGRAM_RECONCILIATION_AND_NEXT_CAPABILITY_DETERMINATION
CROSS_TURN_TRANSITION_VALIDATION=
ALREADY_IMPLEMENTED_AND_VALIDATED
PRIOR_SUCCESSOR_PRIORITY_CLASSIFICATION=
SUPERSEDED_BY_REPOSITORY_EVIDENCE
PRIOR_UNRESOLVED_CAPABILITY_GAP=
NONE
USER_IMPLEMENTATION_AUTHORIZATION=
GRANTED_BUT_NOT_CONSUMED
NEW_IMPLEMENTATION_REQUIRED=
NO
IMPLEMENTATION_STARTED=
NO
PRODUCTION_CHANGE=
NONE
CURRENT_DEFERRED_WORK=
PRESERVED_WITHOUT_PRIORITY_PROMOTION
SUCCESSOR_MILESTONE=
NOT_YET_ESTABLISHED
SUCCESSOR_PHASE=
NOT_YET_ESTABLISHED
SUCCESSOR_CORRIDOR=
NOT_YET_ESTABLISHED
NEXT_ACTION=
REASSESS_REMAINING_PROGRAM_GAPS_FROM_CORRECTED_CAPABILITY_BASELINE
MAP

changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-successor-capability-and-program-priority-state\.sh$' ||
  true
)"

[[ -z "$changed" ]] || {
  echo "STOP: files outside successor-state reconciliation scope changed:"
  printf '%s\n' "$changed"
  exit 2
}

git diff --check
