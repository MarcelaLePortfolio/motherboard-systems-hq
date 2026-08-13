#!/usr/bin/env bash
set -euo pipefail

echo "=== RECOVER SUCCESSOR SELECTION FROM SEMANTIC HISTORY CLOSURE EVIDENCE ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor e5b1f8ce HEAD

closure="scripts/classify-semantic-history-context-optimization-milestone-closure.sh"
post_state="scripts/reconcile-post-semantic-history-context-optimization-program-state.sh"
successor="scripts/classify-post-semantic-history-successor-milestone.sh"

test -f "$closure"
test -f "$post_state"
test -f "$successor"

grep -q 'MILESTONE_STATUS=' "$closure"
grep -q 'CLOSED' "$closure"
grep -q 'COMPLETE_WITH_NO_NEW_OPTIMIZATION_REQUIREMENT_ESTABLISHED' "$closure"

echo "SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=CLOSED"
echo "SUCCESSOR_HYPOTHESIS_SEMANTIC_HISTORY_AS_NEW_MILESTONE=INVALIDATED"

echo
echo "=== REVERT INCORRECT SUCCESSOR-SCOPE ARTIFACTS ==="

git revert --no-edit d15662ef
git revert --no-edit 68e8bae2
git revert --no-edit d3e2a0fc
git revert --no-edit 2322ae14

echo
echo "=== VERIFY RECOVERED BASELINE ==="

git merge-base --is-ancestor e5b1f8ce HEAD
test -z "$(git status --porcelain)"

echo "RECOVERY_BASELINE=e5b1f8ce_PLUS_REVERT_COMMITS"
echo "INVESTIGATION_LIFECYCLE_CROSS_TURN_CONTINUITY=ALREADY_IMPLEMENTED"
echo "SEMANTIC_HISTORY_CONTEXT_OPTIMIZATION=ALREADY_CLOSED"
echo "GENERATION_STABILITY=ALREADY_CLOSED"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=RECONCILE_POST_SEMANTIC_HISTORY_PROGRAM_STATE_AND_TRUE_SUCCESSOR"
