#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="52659e4cc"
TARGET="scripts/utils/ollamaChat.ts"
NEW_TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== VALIDATE TRACKED CURRENT TEST SURFACE ==="
echo "HEAD=$EXPECTED_HEAD"
echo "CANONICAL_RUNNER=npx tsx --test"
echo "ATTEMPT_2_REVALIDATION=YES"
echo "ATTEMPT_3_STARTED=NO"
echo "DOGFOOD_RETRY=NO"

grep -q \
  'expectedOutcome must preserve the operation and direction established by the current user request' \
  "$TARGET"

grep -q \
  'Treat preservation requirements as constraints on the requested operation' \
  "$TARGET"

test -f "$NEW_TEST"

echo
echo "=== FOCUSED AUTHORIZED GROUNDING TEST ==="
npx tsx --test "$NEW_TEST"

echo
echo "=== TRACKED OLLAMA CHAT REGRESSION SURFACE ==="
TRACKED_TESTS=()

while IFS= read -r file; do
  TRACKED_TESTS+=("$file")
done < <(
  git ls-files 'scripts/utils/ollamaChat*.test.ts' | sort
)

test "${#TRACKED_TESTS[@]}" -gt 0
printf 'TRACKED_TEST_COUNT=%s\n' "${#TRACKED_TESTS[@]}"
printf '%s\n' "${TRACKED_TESTS[@]}"

npx tsx --test "${TRACKED_TESTS[@]}"

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== BUILD ==="
npm run build

echo
echo "=== AUTHORIZED DIFF SAFETY ==="
if git diff -- "$TARGET" \
  | grep -E '^[+-].*(operationSemanticTerms|preservesOperation|preservesSubject|enforceConcreteOperationPackageSemanticsFidelity|parseStructuredResponse|selectedContextCandidatePositions)' \
  | grep -vE '^\+\+\+|^---' >/dev/null; then
  echo "Unauthorized boundary mutation detected."
  exit 1
fi

echo "FIDELITY_GUARD_CHANGED=NO"
echo "PARSER_CHANGED=NO"
echo "SELECTED_CONTEXT_CONTRACT_CHANGED=NO"
echo "SCHEMA_CHANGED=NO"
echo "AUTHORITY_MODEL_CHANGED=NO"

echo
echo "=== VALIDATION RESULT ==="
echo "AUTHORIZED_GROUNDING_TEST=PASS"
echo "TRACKED_CURRENT_REGRESSION_SURFACE=PASS"
echo "TYPECHECK=PASS"
echo "BUILD=PASS"
echo "ATTEMPT_2_IMPLEMENTATION_STATUS=VALIDATED"
echo "ATTEMPT_3_REQUIRED=NO"
echo "LIVE_DOGFOOD_PERFORMED=NO"

echo
echo "=== STAGE AUTHORIZED FUNCTIONAL PATHS ONLY ==="
git add -- "$TARGET" "$NEW_TEST"

STAGED="$(git diff --cached --name-only)"
printf '%s\n' "$STAGED"

test "$(printf '%s\n' "$STAGED" | sed '/^$/d' | wc -l | tr -d ' ')" = "2"
printf '%s\n' "$STAGED" | grep -qx "$TARGET"
printf '%s\n' "$STAGED" | grep -qx "$NEW_TEST"

git commit -m "Ground package semantics outcome direction"
git push origin "$BRANCH"

echo
echo "AUTHORIZED_FUNCTIONAL_COMMIT_COMPLETE=YES"
echo "NEXT_ACTION=CONTROLLED_RUNTIME_REBUILD_RESTART_BEFORE_ONE_LIVE_DOGFOOD"
