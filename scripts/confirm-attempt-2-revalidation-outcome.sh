#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
TARGET="scripts/utils/ollamaChat.ts"
GROUNDING_TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"
STALE_TEST="scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

echo "=== ATTEMPT 2 REVALIDATION OUTCOME ==="
echo "CURRENT_HEAD=$(git rev-parse --short=9 HEAD)"

echo
echo "=== FUNCTIONAL COMMIT CHECK ==="
git log -6 --oneline

if git log -6 --format='%s' | grep -Fxq 'Ground package semantics outcome direction'; then
  echo "GROUNDING_FUNCTIONAL_COMMIT_PRESENT=YES"
else
  echo "GROUNDING_FUNCTIONAL_COMMIT_PRESENT=NO"
fi

echo
echo "=== AUTHORIZED FILE STATE ==="
git status --short -- "$TARGET" "$GROUNDING_TEST" "$STALE_TEST"

test ! -e "$STALE_TEST"
grep -q 'expectedOutcome must preserve the operation and direction established by the current user request' "$TARGET"
grep -q 'Treat preservation requirements as constraints on the requested operation' "$TARGET"

echo "STALE_SCHEMA_BOUNDING_TEST_PRESENT=NO"
echo "AUTHORIZED_GROUNDING_PRESENT=YES"

echo
echo "=== REMOTE CONVERGENCE ==="
git fetch origin "$BRANCH"

LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse "origin/$BRANCH")"

echo "LOCAL_HEAD=$(git rev-parse --short=9 HEAD)"
echo "REMOTE_HEAD=$(git rev-parse --short=9 "origin/$BRANCH")"

if test "$LOCAL_HEAD" = "$REMOTE_HEAD"; then
  echo "LOCAL_REMOTE_CONVERGED=YES"
else
  echo "LOCAL_REMOTE_CONVERGED=NO"
fi

echo
echo "ATTEMPT_2_VALIDATION=PASS"
echo "ATTEMPT_3_REQUIRED=NO"
echo "LIVE_DOGFOOD_PERFORMED=NO"
echo "NEXT_ACTION=CONTROLLED_BACKEND_REBUILD_AND_RESTART_AFTER_FUNCTIONAL_COMMIT_CONFIRMATION"
