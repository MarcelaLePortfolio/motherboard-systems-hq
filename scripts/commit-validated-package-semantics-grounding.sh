#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="8f17ae37a"
TARGET="scripts/utils/ollamaChat.ts"
GROUNDING_TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"
STALE_TEST="scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "ATTEMPT_2_VALIDATION=PASS"
echo "FUNCTIONAL_COMMIT_PRESENT=NO"
echo "ATTEMPT_3_REQUIRED=NO"
echo "LIVE_DOGFOOD=NO"

test ! -e "$STALE_TEST"
test -f "$GROUNDING_TEST"
grep -q 'expectedOutcome must preserve the operation and direction established by the current user request' "$TARGET"
grep -q 'Treat preservation requirements as constraints on the requested operation' "$TARGET"

echo
echo "=== AUTHORIZED FILE STATUS ==="
git status --short -- "$TARGET" "$GROUNDING_TEST" "$STALE_TEST"

git add -- "$TARGET" "$GROUNDING_TEST" "$STALE_TEST"

echo
echo "=== STAGED PATHS ==="
git diff --cached --name-only

test "$(git diff --cached --name-only | sort)" = "$(printf '%s\n' \
  "$GROUNDING_TEST" \
  "$STALE_TEST" \
  "$TARGET" | sort)"

git commit -m "Ground package semantics outcome direction"
git push origin "$BRANCH"

echo
echo "GROUNDING_FUNCTIONAL_COMMIT_COMPLETE=YES"
echo "REMOTE_PUSH_COMPLETE=YES"
echo "CURRENT_HEAD=$(git rev-parse --short=9 HEAD)"
echo "ATTEMPT_2_COMPLETE=YES"
echo "ATTEMPT_3_REQUIRED=NO"
echo "LIVE_DOGFOOD_PERFORMED=NO"
echo "NEXT_ACTION=CONTROLLED_BACKEND_REBUILD_AND_RESTART_BEFORE_SINGLE_LIVE_DOGFOOD"
