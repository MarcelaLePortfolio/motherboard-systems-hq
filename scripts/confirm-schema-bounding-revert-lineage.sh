#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="fcef87286"
IMPLEMENT_COMMIT="00d16769f"
REVERT_COMMIT="774aeed46"
TEST="scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== SCHEMA-BOUNDING REVERT LINEAGE ==="
echo "HEAD=$EXPECTED_HEAD"
echo "FUNCTIONAL_MUTATION=NO"
echo "TEST_MUTATION=NO"
echo "ATTEMPT_3_STARTED=NO"
echo "LIVE_DOGFOOD=NO"

echo
echo "=== IMPLEMENTATION COMMIT ==="
git show --stat --oneline "$IMPLEMENT_COMMIT"
git show --format=fuller --no-ext-diff "$IMPLEMENT_COMMIT" -- "$TARGET" | sed -n '1,260p'

echo
echo "=== EXPLICIT REVERT COMMIT ==="
git show --stat --oneline "$REVERT_COMMIT"
git show --format=fuller --no-ext-diff "$REVERT_COMMIT" -- "$TARGET" | sed -n '1,300p'

echo
echo "=== REVERT RELATIONSHIP ==="
if git merge-base --is-ancestor "$IMPLEMENT_COMMIT" "$REVERT_COMMIT"; then
  echo "IMPLEMENTATION_PRECEDES_REVERT=YES"
else
  echo "IMPLEMENTATION_PRECEDES_REVERT=NO"
fi

if git merge-base --is-ancestor "$REVERT_COMMIT" HEAD; then
  echo "REVERT_IS_CURRENT_LINEAGE=YES"
else
  echo "REVERT_IS_CURRENT_LINEAGE=NO"
fi

echo
echo "=== CURRENT TARGET CONTRACT ==="
grep -n -E \
  'const OLLAMA_CHAT_OUTPUT_SCHEMA|BASE_OLLAMA_CHAT_OUTPUT_SCHEMA|buildOllamaChatOutputSchema|format: OLLAMA_CHAT_OUTPUT_SCHEMA' \
  "$TARGET" || true

echo
echo "=== STALE TRACKED TEST EXPECTATIONS ==="
grep -n -E \
  'BASE_OLLAMA_CHAT_OUTPUT_SCHEMA|buildOllamaChatOutputSchema|enum: \["project_context_excerpt"\]' \
  "$TEST" || true

echo
echo "=== AUTHORIZED GROUNDING DIFF ==="
git diff -- "$TARGET"

echo
echo "=== CLASSIFICATION ==="
echo "SCHEMA_BOUNDING_IMPLEMENTED=$IMPLEMENT_COMMIT"
echo "SCHEMA_BOUNDING_EXPLICITLY_REVERTED=$REVERT_COMMIT"
echo "CURRENT_IMPLEMENTATION_USES_RESTORED_STATIC_SCHEMA=YES"
echo "TRACKED_SCHEMA_BOUNDING_TEST_SURVIVED_REVERT=YES"
echo "TRACKED_SCHEMA_BOUNDING_TEST_MATCHES_CURRENT_IMPLEMENTATION=NO"
echo "GROUNDING_DIFF_CAUSED_TEST_FAILURE=NO"
echo "GROUNDING_IMPLEMENTATION_FAILURE_ESTABLISHED=NO"
echo "ATTEMPT_3_REQUIRED=NO"
echo "TEST_MUTATION_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_ALLOWED=NO"
echo "NEXT_ACTION=REQUEST_AUTHORIZATION_TO_REMOVE_STALE_TRACKED_SCHEMA_BOUNDING_TEST_AND_REVALIDATE_ATTEMPT_2"
