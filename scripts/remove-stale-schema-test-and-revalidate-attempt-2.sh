#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="607af44fa"
STALE_TEST="scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts"
TARGET="scripts/utils/ollamaChat.ts"
GROUNDING_TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "AUTHORIZATION_CONFIRMED=YES"
echo "AUTHORIZED_STALE_TEST_REMOVAL=YES"
echo "ATTEMPT_2_REVALIDATION=YES"
echo "ATTEMPT_3_STARTED=NO"
echo "LIVE_DOGFOOD=NO"

test -f "$STALE_TEST"
git ls-files --error-unmatch "$STALE_TEST" >/dev/null

grep -q 'buildOllamaChatOutputSchema' "$STALE_TEST"
grep -q 'BASE_OLLAMA_CHAT_OUTPUT_SCHEMA' "$STALE_TEST"

grep -q 'const OLLAMA_CHAT_OUTPUT_SCHEMA' "$TARGET"
! grep -q 'function buildOllamaChatOutputSchema' "$TARGET"
! grep -q 'const BASE_OLLAMA_CHAT_OUTPUT_SCHEMA' "$TARGET"

rm -- "$STALE_TEST"

echo
echo "=== FOCUSED GROUNDING VALIDATION ==="
npx tsx --test "$GROUNDING_TEST"

echo
echo "=== TRACKED CURRENT OLLAMA CHAT TEST SURFACE ==="
mapfile -t TRACKED_TESTS < <(
  git ls-files 'scripts/utils/ollamaChat*.test.ts' |
    grep -v '^scripts/utils/ollamaChat\.empty-history-schema-bounding\.test\.ts$'
)

test "${#TRACKED_TESTS[@]}" -gt 0
npx tsx --test "${TRACKED_TESTS[@]}"

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== BUILD ==="
npm run build

echo
echo "=== AUTHORIZED GROUNDING DIFF ==="
git diff -- "$TARGET" "$GROUNDING_TEST" "$STALE_TEST"

echo
echo "=== SAFETY CHECK ==="
test ! -e "$STALE_TEST"
grep -q 'expectedOutcome must preserve the operation and direction established by the current user request' "$TARGET"
grep -q 'Treat preservation requirements as constraints on the requested operation' "$TARGET"

echo "STALE_SCHEMA_BOUNDING_TEST_REMOVED=YES"
echo "GROUNDING_IMPLEMENTATION_VALIDATED=YES"
echo "ATTEMPT_2_VALIDATION=PASS"
echo "ATTEMPT_3_REQUIRED=NO"
echo "LIVE_DOGFOOD_PERFORMED=NO"

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
echo "NEXT_ACTION=CONTROLLED_BACKEND_REBUILD_AND_RESTART_BEFORE_SINGLE_LIVE_DOGFOOD"
