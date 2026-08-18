#!/usr/bin/env bash
set -euo pipefail

echo "=== POST PHASE 3 — BROADER PROGRAM STATE / DEFERRED WORK RECONCILIATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-post-phase-3-broader-program-state-and-deferred-work\.sh$|^ M scripts/reconcile-post-phase-3-broader-program-state-and-deferred-work\.sh$' ||
  true
)"
test -z "$unexpected"

test -f scripts/reconcile-current-deferred-work-inventory.sh
test -f scripts/classify-deferred-work-inventory.sh
test -f scripts/reconcile-current-successor-priority-boundary.sh
test -f scripts/classify-post-phase-3-successor-scope.sh

echo "=== CURRENT DEFERRED WORK SIGNALS ==="
grep -RIn -E \
  'DEFERRED|UNRESOLVED|NEXT_MILESTONE|SUCCESSOR_PRIORITY|SEMANTIC_HISTORY|GENERATION_STABILITY|BEHAVIORAL_RELIABILITY' \
  scripts/reconcile-current-deferred-work-inventory.sh \
  scripts/classify-deferred-work-inventory.sh \
  scripts/reconcile-current-successor-priority-boundary.sh \
  scripts/classify-post-phase-3-successor-scope.sh \
  2>/dev/null || true

cat <<'MAP'
PROGRAM=MATILDA_CONVERSATION_ENGINE
STATUS=BROADER_PROGRAM_STATE_RECONCILIATION_ACTIVE

PHASE_3_REASONING_STATUS_PRODUCTION_BEHAVIOR=CLOSED_BOUNDED
PHASE_3_DR=20260818_102518
PHASE_3_REOPENED=NO

GENERATION_STABILITY=ALREADY_CLOSED
GENERATION_STABILITY_REOPENED=NO

REASONING_STATUS_MODEL_BEHAVIORAL_RELIABILITY=SEPARATELY_DEFERRED
REASONING_STATUS_RELIABILITY_REPLAY_AUTHORIZED=NO

CURRENT_INVENTORIED_RUNTIME_CAPABILITY_GAPS=ZERO
CURRENT_RUNTIME_SUCCESSOR=NONE_ESTABLISHED

RECONCILIATION_SCOPE=REVIEW_EXISTING_DEFERRED_WORK_AND_PROGRAM_LEVEL_CANDIDATES_WITHOUT_PROMOTING_ANY_ITEM_UNLESS_CURRENT_REPOSITORY_EVIDENCE_ESTABLISHES_A_GENUINE_UNRESOLVED_CAPABILITY_OR_AUTHORIZED_PROGRAM_PRIORITY

IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_CHANGE=NONE
DR_NOW=NO

NEXT_ACTION=CLASSIFY_CURRENT_DEFERRED_WORK_INTO_COMPLETED__SEPARATELY_DEFERRED__NON_CAPABILITY_CONDITION__OR_EVIDENCE_SUPPORTED_SUCCESSOR_CANDIDATE
MAP
