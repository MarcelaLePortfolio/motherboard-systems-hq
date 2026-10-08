#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
WORKFLOW="server/matilda-chat-workflow.ts"
MODULE="server/matilda-request-explicit-package-semantics.ts"
TEST="server/matilda-request-explicit-package-semantics.test.ts"
ROLLBACK_SCRIPT="scripts/verify-request-explicit-projection-rollback.sh"

echo "=== CHECKPOINT ==="
git branch --show-current
git rev-parse --short=9 HEAD

test "$(git branch --show-current)" = "$BRANCH"

echo
echo "=== ROLLBACK SCRIPT PRECONDITIONS ==="
nl -ba "$ROLLBACK_SCRIPT" | sed -n '1,125p'

echo
echo "=== EXPECTED HEAD VERSUS ACTUAL HEAD ==="
rg -n 'EXPECTED_HEAD|rev-parse|test ' "$ROLLBACK_SCRIPT"
git rev-parse --short=9 HEAD

echo
echo "=== FUNCTIONAL SOURCE STATUS ==="
git status --short -- "$WORKFLOW" "$MODULE" "$TEST"

echo
echo "=== REVIEWED WORKFLOW DIFF ==="
git diff -- "$WORKFLOW"

echo
echo "=== PROJECTION FILE TRACKING ==="
git ls-files -- "$MODULE" "$TEST"

echo
echo "=== CLASSIFICATION ==="
echo "ROLLBACK=INCOMPLETE"
echo "LIKELY_BLOCKER=STALE_EXPECTED_HEAD"
echo "SOURCE_MUTATION=NONE"
echo "FUNCTIONAL_COMMIT=NONE"
echo "DOGFOOD=NONE"
echo "NEXT_ACTION=REVIEW_PRECONDITIONS_BEFORE_BOUNDED_ROLLBACK"
