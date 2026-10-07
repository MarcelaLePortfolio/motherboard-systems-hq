#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="c99784acd"
STABLE_BASE="8f17ae37af201514db3e436d31383170ab1a0dbc"

TARGET="scripts/utils/ollamaChat.ts"
ATTEMPT2_TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"
ATTEMPT3_TEST="scripts/utils/ollamaChat.package-semantics-current-request-grounding.test.ts"
STALE_TEST="scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== AUTHORIZED TARGETED REVERT ==="
echo "AUTHORIZATION=I authorize the targeted Package Semantics grounding revert."
echo "STABLE_BASE=$STABLE_BASE"
echo "HISTORY_REWRITE=NO"
echo "FORCE_PUSH=NO"
echo "DOGFOOD_PERFORMED=NO"

# Restore only the production source to the verified pre-Attempt-2 state.
git restore --source="$STABLE_BASE" -- "$TARGET"

# Remove only the tests introduced by the failed grounding attempts.
rm -f -- "$ATTEMPT2_TEST" "$ATTEMPT3_TEST"

# Preserve the separately authorized stale-test deletion.
if [ -e "$STALE_TEST" ]; then
  echo "ERROR=STALE_SCHEMA_BOUNDING_TEST_UNEXPECTEDLY_PRESENT"
  exit 1
fi

echo
echo "=== SCOPE VALIDATION ==="

EXPECTED_PATHS="$(printf '%s\n' \
  "$TARGET" \
  "$ATTEMPT2_TEST" \
  "$ATTEMPT3_TEST" | sort)"

ACTUAL_PATHS="$(git diff --name-only -- \
  "$TARGET" \
  "$ATTEMPT2_TEST" \
  "$ATTEMPT3_TEST" | sort)"

test "$ACTUAL_PATHS" = "$EXPECTED_PATHS"

# Prove the production source now exactly matches the stable base.
test -z "$(git diff "$STABLE_BASE" -- "$TARGET")"

# Prove failed-attempt tests are absent.
test ! -e "$ATTEMPT2_TEST"
test ! -e "$ATTEMPT3_TEST"

echo "TARGET_SOURCE_MATCHES_STABLE_BASE=YES"
echo "ATTEMPT_2_GROUNDING_TEST_REMOVED=YES"
echo "ATTEMPT_3_GROUNDING_TEST_REMOVED=YES"
echo "STALE_SCHEMA_BOUNDING_TEST_REMAINS_DELETED=YES"

echo
echo "=== VALIDATION ==="
npx tsc --noEmit
npm run build

echo
echo "TYPECHECK=PASS"
echo "BUILD=PASS"
echo "DOGFOOD_PERFORMED=NO"

echo
echo "=== AUTHORIZED DIFF ==="
git diff -- "$TARGET" "$ATTEMPT2_TEST" "$ATTEMPT3_TEST"

git add -- "$TARGET" "$ATTEMPT2_TEST" "$ATTEMPT3_TEST"

STAGED_PATHS="$(git diff --cached --name-only | sort)"
test "$STAGED_PATHS" = "$EXPECTED_PATHS"

git commit -m "Revert failed package semantics grounding attempts"
git push origin "$BRANCH"

echo
echo "=== REVERT COMPLETE ==="
echo "TARGETED_GROUNDING_REVERT=COMPLETE"
echo "REMOTE_CONVERGENCE=$(test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")" && echo YES || echo NO)"
echo "DOGFOOD_RETRY_PERFORMED=NO"
echo "NEXT_ACTION=REASSESS_PACKAGE_SEMANTICS_FAILURE_FROM_STABLE_BOUNDARY"
