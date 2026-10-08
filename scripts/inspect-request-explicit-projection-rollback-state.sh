#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
WORKFLOW="server/matilda-chat-workflow.ts"
MODULE="server/matilda-request-explicit-package-semantics.ts"
TEST="server/matilda-request-explicit-package-semantics.test.ts"

echo "=== CURRENT CHECKPOINT ==="
git rev-parse --short=9 HEAD

echo
echo "=== BRANCH VERIFICATION ==="
test "$(git branch --show-current)" = "$BRANCH"
echo "BRANCH=VERIFIED"

echo
echo "=== ROLLBACK STATE ==="
git status --short -- "$WORKFLOW" "$MODULE" "$TEST"

if git diff --quiet HEAD -- "$WORKFLOW" \
  && test ! -e "$MODULE" \
  && test ! -e "$TEST"; then
  echo "ROLLBACK=COMPLETE"
else
  echo "ROLLBACK=INCOMPLETE"
  echo "NEXT_ACTION=INSPECT_EXISTING_ROLLBACK_SCRIPT_PRECONDITIONS"
  echo "NO_ADDITIONAL_SOURCE_MUTATION_AUTHORIZED"
  exit 1
fi

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TYPECHECK=PASS"

echo
echo "=== FINAL CLASSIFICATION ==="
echo "SOURCE_BASELINE=RESTORED"
echo "FUNCTIONAL_SOURCE_COMMIT=NONE"
echo "DOGFOOD=NONE"
echo "NEXT_ACTION=REASSESS_UPSTREAM_VALIDATION_SEAM"
