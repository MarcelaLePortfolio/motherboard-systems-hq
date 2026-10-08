#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
WORKFLOW="server/matilda-chat-workflow.ts"
MODULE="server/matilda-request-explicit-package-semantics.ts"
TEST="server/matilda-request-explicit-package-semantics.test.ts"

test "$(git branch --show-current)" = "$BRANCH"

echo "=== REPOSITORY CHECKPOINT ==="
git rev-parse --short=9 HEAD
git status --short -- "$WORKFLOW" "$MODULE" "$TEST"

echo
echo "=== REMOTE CONVERGENCE ==="
git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
echo "REMOTE_CONVERGENCE=PASS"

echo
echo "=== ROLLBACK CLASSIFICATION ==="

if git diff --quiet HEAD -- "$WORKFLOW" \
  && test ! -e "$MODULE" \
  && test ! -e "$TEST"; then
  echo "ROLLBACK=COMPLETE"
else
  echo "ROLLBACK=NOT_VERIFIED"
  echo "REQUIRED_ACTION=RUN_EXISTING_ROLLBACK_SCRIPT"
  echo "COMMAND=./scripts/verify-request-explicit-projection-rollback.sh"
  exit 1
fi

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TYPECHECK=PASS"

echo
echo "=== FINAL STATE ==="
echo "BLOCKED_IMPLEMENTATION=ABANDONED"
echo "UPSTREAM_VALIDATION_SEAM=REQUIRES_REASSESSMENT"
echo "FUNCTIONAL_SOURCE_COMMIT=NONE"
echo "DOGFOOD=NONE"
echo "NEXT_ACTION=COLLABORATIVE_ARCHITECTURAL_REASSESSMENT"
