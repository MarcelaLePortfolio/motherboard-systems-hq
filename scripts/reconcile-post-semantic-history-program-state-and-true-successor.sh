#!/usr/bin/env bash
set -euo pipefail

echo "=== RECONCILE POST-SEMANTIC-HISTORY PROGRAM STATE AND TRUE SUCCESSOR ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor ccf2ce70 HEAD

echo "=== VERIFY RECOVERY STATE ==="
recovery="scripts/recover-successor-selection-from-semantic-history-closure-evidence.sh"
test -f "$recovery"
grep -q 'SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=CLOSED' "$recovery"
grep -q 'INVESTIGATION_LIFECYCLE_CROSS_TURN_CONTINUITY=ALREADY_IMPLEMENTED' "$recovery"
grep -q 'GENERATION_STABILITY=ALREADY_CLOSED' "$recovery"
echo "RECOVERY_STATE=CONFIRMED"

echo
echo "=== VERIFY POST-SEMANTIC-HISTORY PROGRAM STATE ==="
post_state="scripts/reconcile-post-semantic-history-context-optimization-program-state.sh"
test -f "$post_state"

grep -nE \
  'SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=|CLOSED|NEXT|SUCCESSOR|MILESTONE|PROGRAM|DEFERRED|CAPABILITY' \
  "$post_state" || true

echo
echo "=== VERIFY POST-SEMANTIC-HISTORY SUCCESSOR CLASSIFICATION ==="
successor="scripts/classify-post-semantic-history-successor-milestone.sh"
test -f "$successor"

grep -nE \
  'SUCCESSOR_MILESTONE=|NEXT_CORRIDOR=|NEXT_ACTION=|PROGRAM_RECONCILIATION|CAPABILITY|DEFERRED|IMPLEMENTATION_AUTHORIZED|PRODUCTION_CHANGE' \
  "$successor" || true

echo
echo "=== VERIFY CURRENT COMPLETED CAPABILITY / GAP INVENTORY ARTIFACTS ==="
artifacts=(
  scripts/classify-completed-runtime-capability-inventory.sh
  scripts/classify-deferred-work-inventory.sh
  scripts/classify-unresolved-capability-gaps.sh
  scripts/classify-successor-priority-boundary.sh
  scripts/reconcile-existing-cross-turn-transition-validation-implementation-state.sh
  scripts/reconcile-successor-capability-and-program-priority-state.sh
  scripts/reassess-remaining-program-gaps-from-corrected-baseline.sh
  scripts/classify-post-collaboration-runtime-capability-state.sh
)

for artifact in "${artifacts[@]}"; do
  if [[ -f "$artifact" ]]; then
    echo "PRESENT=$artifact"
  fi
done

echo
echo "=== INSPECT CURRENT REMAINING-GAP / PRIORITY SIGNALS ==="
grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'remaining gap|remaining capability|successor priority|next canonical milestone|next milestone|deferred work|not implemented|not yet established|candidate successor|program reconciliation' \
  scripts/classify-completed-runtime-capability-inventory.sh \
  scripts/classify-deferred-work-inventory.sh \
  scripts/classify-unresolved-capability-gaps.sh \
  scripts/classify-successor-priority-boundary.sh \
  scripts/reconcile-successor-capability-and-program-priority-state.sh \
  scripts/reassess-remaining-program-gaps-from-corrected-baseline.sh \
  scripts/classify-post-collaboration-runtime-capability-state.sh \
  2>/dev/null | head -320 || true

echo
echo "=== TRUE SUCCESSOR RECONCILIATION BOUNDARY ==="
cat <<'MAP'
CURRENT_PROGRAM=
MATILDA_CONVERSATION_ENGINE

GENERATION_STABILITY=
CLOSED

SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=
CLOSED

INVESTIGATION_LIFECYCLE_CROSS_TURN_VALIDATION=
IMPLEMENTED_AND_VALIDATED

PREVIOUS_SUCCESSOR_HYPOTHESES=
INVALIDATED_AS_ALREADY_COMPLETE

SUCCESSOR_SELECTION_MODE=
CURRENT_REPOSITORY_CAPABILITY_AND_GAP_RECONCILIATION

TRUE_SUCCESSOR_MILESTONE=
NOT_YET_SELECTED

IMPLEMENTATION_AUTHORIZED=
NO

IMPLEMENTATION_STARTED=
NO

PRODUCTION_GENERATION_POLICY_REOPENED=
NO

PRODUCTION_CHANGE=
NONE

NEXT_ACTION=
CLASSIFY_TRUE_REMAINING_CONVERSATION_ENGINE_CAPABILITY_GAPS_AND_PRIORITY
MAP
