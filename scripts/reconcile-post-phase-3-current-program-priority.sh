#!/usr/bin/env bash
set -euo pipefail

echo "=== POST PHASE 3 — CURRENT PROGRAM PRIORITY RECONCILIATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor d4c37176 HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-post-phase-3-current-program-priority\.sh$|^ M scripts/reconcile-post-phase-3-current-program-priority\.sh$' ||
  true
)"
test -z "$unexpected"

test -f scripts/reconcile-current-successor-priority-boundary.sh

grep -Fq 'SUCCESSOR_PRIORITY=' scripts/reconcile-current-successor-priority-boundary.sh
grep -Fq 'NONE_ESTABLISHED_ON_CURRENT_INVENTORIED_SURFACE' scripts/reconcile-current-successor-priority-boundary.sh
grep -Fq 'NEXT_MILESTONE_CANDIDATE=' scripts/reconcile-current-successor-priority-boundary.sh
grep -Fq 'NONE_ESTABLISHED' scripts/reconcile-current-successor-priority-boundary.sh
grep -Fq 'NO_EVIDENCE_SUPPORTED_RUNTIME_SUCCESSOR_ESTABLISHED' scripts/reconcile-current-successor-priority-boundary.sh

cat <<'MAP'
PROGRAM=MATILDA_CONVERSATION_ENGINE
STATUS=POST_PHASE_3_PROGRAM_PRIORITY_RECONCILED

PHASE_3_STATUS=CLOSED_BOUNDED
PHASE_3_DR=20260818_102518
PHASE_3_REOPENED=NO

REASONING_STATUS_BEHAVIORAL_RELIABILITY=SEPARATELY_DEFERRED
GENERATION_STABILITY_MILESTONE=ALREADY_CLOSED
GENERATION_STABILITY_REOPENED=NO

CURRENT_INVENTORIED_UNRESOLVED_CAPABILITY_GAPS=ZERO
CURRENT_EVIDENCE_SUPPORTED_RUNTIME_SUCCESSOR=NONE_ESTABLISHED
NEXT_MILESTONE_CANDIDATE=NONE_ESTABLISHED

SUCCESSOR_SELECTION_RESULT=DO_NOT_INVENT_OR_PROMOTE_A_NEW_RUNTIME_MILESTONE_FROM_THE_CURRENT_INVENTORY
IMPLEMENTATION_READINESS=NOT_APPLICABLE
IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_CHANGE=NONE
DR_NOW=NO

NEXT_ACTION=RECONCILE_BROADER_PROGRAM_STATE_AND_DEFERRED_WORK_INVENTORY_BEFORE_ANY_NEW_MILESTONE_SELECTION
MAP
