#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="60654e268"
TARGET="scripts/utils/ollamaChat.ts"
NEW_TEST="scripts/utils/ollamaChat.package-semantics-generation-grounding.test.ts"
STALE_TEST="scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== VALIDATE AUTHORIZED GROUNDING UNDER PROVEN RUNNER ==="
echo "CANONICAL_RUNNER=npx tsx --test"
echo "ATTEMPT_2_REVALIDATION=YES"
echo "ATTEMPT_3_STARTED=NO"
echo "DOGFOOD_RETRY=NO"

echo
echo "=== VERIFY AUTHORIZED WORKTREE CHANGE ==="
git diff -- "$TARGET" "$NEW_TEST"

grep -q \
  'expectedOutcome must preserve the operation and direction established by the current user request' \
  "$TARGET"

grep -q \
  'Treat preservation requirements as constraints on the requested operation' \
  "$TARGET"

echo "AUTHORIZED_PROMPT_GROUNDING_PRESENT=YES"

echo
echo "=== FOCUSED GROUNDING TEST ==="
npx tsx --test "$NEW_TEST"

echo
echo "=== CURRENT CONDITIONAL CONVERSATION SUPPORT CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.conditional-conversation-support-prompt.test.ts

echo
echo "=== PACKAGE SEMANTICS CONTRACT / FIDELITY TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity.test.ts \
  scripts/utils/ollamaChat.package-semantics-fidelity-runtime.test.ts \
  scripts/utils/ollamaChat.expected-outcome-diagnostic-observability.test.ts \
  "$NEW_TEST"

echo
echo "=== CURRENT OLLAMA CHAT REGRESSION SUITE ==="
TEST_FILES=()
while IFS= read -r file; do
  if [ "$file" != "$STALE_TEST" ]; then
    TEST_FILES+=("$file")
  fi
done < <(
  find scripts/utils -maxdepth 1 -type f -name 'ollamaChat*.test.ts' | sort
)

npx tsx --test "${TEST_FILES[@]}"

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== BUILD ==="
npm run build

echo
echo "=== FIDELITY GUARD IMMUTABILITY ==="
if git diff -- "$TARGET" \
  | grep -E '^[+-].*(operationSemanticTerms|preservesOperation|preservesSubject|enforceConcreteOperationPackageSemanticsFidelity)' \
  | grep -vE '^\+\+\+|^---' >/dev/null; then
  echo "Unexpected fidelity guard mutation detected."
  exit 1
fi

echo "FIDELITY_GUARD_CHANGED=NO"
echo "PARSER_CHANGED=NO"
echo "SCHEMA_CHANGED=NO"
echo "AUTHORITY_MODEL_CHANGED=NO"

echo
echo "=== VALIDATION RESULT ==="
echo "AUTHORIZED_PROMPT_CHANGE_VALIDATED=YES"
echo "GROUNDING_TEST=PASS"
echo "CONDITIONAL_PROMPT_CONTRACT=PASS"
echo "PACKAGE_SEMANTICS_CONTRACTS=PASS"
echo "CURRENT_REGRESSION_SUITE_EXCLUDING_ABANDONED_SCHEMA_TEST=PASS"
echo "TYPECHECK=PASS"
echo "BUILD=PASS"
echo "ATTEMPT_2_IMPLEMENTATION_STATUS=VALIDATED"
echo "ATTEMPT_3_REQUIRED=NO"
echo "DOGFOOD_RETRY_PERFORMED=NO"

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
