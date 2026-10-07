#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
STABLE_BASE="8f17ae37af201514db3e436d31383170ab1a0dbc"

TARGET="scripts/utils/ollamaChat.ts"
ATTEMPT2_TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"
ATTEMPT3_TEST="scripts/utils/ollamaChat.package-semantics-current-request-grounding.test.ts"
STALE_TEST="scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

git fetch origin "$BRANCH"

LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse "origin/$BRANCH")"
test "$LOCAL_HEAD" = "$REMOTE_HEAD"

echo "=== AUTHORIZED TARGETED REVERT ==="
echo "AUTHORIZATION_PRESENT=YES"
echo "REMOTE_CONVERGENCE_BEFORE=YES"
echo "STABLE_BASE=$STABLE_BASE"
echo "HISTORY_REWRITE=NO"
echo "FORCE_PUSH=NO"
echo "DOGFOOD_PERFORMED=NO"

git restore --source="$STABLE_BASE" -- "$TARGET"
rm -f -- "$ATTEMPT2_TEST" "$ATTEMPT3_TEST"

if [ -e "$STALE_TEST" ]; then
  echo "ERROR=STALE_SCHEMA_BOUNDING_TEST_UNEXPECTEDLY_PRESENT"
  exit 1
fi

test -z "$(git diff "$STABLE_BASE" -- "$TARGET")"
test ! -e "$ATTEMPT2_TEST"
test ! -e "$ATTEMPT3_TEST"

echo "TARGET_SOURCE_MATCHES_STABLE_BASE=YES"
echo "ATTEMPT_2_GROUNDING_TEST_REMOVED=YES"
echo "ATTEMPT_3_GROUNDING_TEST_REMOVED=YES"
echo "STALE_SCHEMA_BOUNDING_TEST_REMAINS_DELETED=YES"

npx tsc --noEmit
npm run build

echo "TYPECHECK=PASS"
echo "BUILD=PASS"
echo "DOGFOOD_PERFORMED=NO"

git add -- "$TARGET" "$ATTEMPT2_TEST" "$ATTEMPT3_TEST"

EXPECTED_STAGED="$(printf '%s\n' \
  "$TARGET" \
  "$ATTEMPT2_TEST" \
  "$ATTEMPT3_TEST" | sort)"

ACTUAL_STAGED="$(git diff --cached --name-only | sort)"
test "$ACTUAL_STAGED" = "$EXPECTED_STAGED"

git commit -m "Revert failed package semantics grounding attempts"
git push origin "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "TARGETED_GROUNDING_REVERT=COMPLETE"
echo "REMOTE_CONVERGENCE=YES"
echo "DOGFOOD_RETRY_PERFORMED=NO"
echo "NEXT_ACTION=REASSESS_PACKAGE_SEMANTICS_FAILURE_FROM_STABLE_BOUNDARY"
