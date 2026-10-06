#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="26aca87f8"
TEST="scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts"
TARGET="scripts/utils/ollamaChat.ts"
ORIGIN_COMMIT="c8b4cf51d"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== EMPTY-HISTORY SCHEMA TEST STATUS CLASSIFICATION ==="
echo "HEAD=$EXPECTED_HEAD"
echo "FUNCTIONAL_MUTATION=NO"
echo "TEST_MUTATION=NO"
echo "DOGFOOD_RETRY=NO"
echo "ATTEMPT_3_STARTED=NO"

echo
echo "=== TRACKED TEST ORIGIN ==="
git show --stat --oneline "$ORIGIN_COMMIT"
git show --format=fuller --no-ext-diff "$ORIGIN_COMMIT" -- "$TEST" "$TARGET" | sed -n '1,260p'

echo
echo "=== ORIGIN COMMIT RELATIONSHIP TO CURRENT HEAD ==="
if git merge-base --is-ancestor "$ORIGIN_COMMIT" HEAD; then
  echo "ORIGIN_COMMIT_IS_ANCESTOR=YES"
else
  echo "ORIGIN_COMMIT_IS_ANCESTOR=NO"
fi

echo
echo "=== SUBSEQUENT HISTORY FOR TEST AND TARGET ==="
git log --oneline --decorate "$ORIGIN_COMMIT"..HEAD -- "$TEST" "$TARGET" | head -80 || true

echo
echo "=== TEST EXPECTATIONS ==="
grep -n -E \
  'buildOllamaChatOutputSchema|BASE_OLLAMA_CHAT_OUTPUT_SCHEMA|allowedConversationSupportSourceIds|enum: \["project_context_excerpt"\]' \
  "$TEST" || true

echo
echo "=== CURRENT TARGET SCHEMA CONTRACT ==="
grep -n -E \
  'const OLLAMA_CHAT_OUTPUT_SCHEMA|buildOllamaChatOutputSchema|BASE_OLLAMA_CHAT_OUTPUT_SCHEMA|format: OLLAMA_CHAT_OUTPUT_SCHEMA' \
  "$TARGET" || true

echo
echo "=== AUTHORIZED GROUNDING DIFF ==="
git diff -- "$TARGET"

echo
echo "=== CLASSIFICATION ==="
echo "TRACKED_TEST=YES"
echo "TEST_ORIGIN=$ORIGIN_COMMIT"
echo "AUTHORIZED_GROUNDING_DIFF_TOUCHES_SCHEMA_BOUNDING=NO"
echo "GROUNDING_IMPLEMENTATION_FAILURE_ESTABLISHED=NO"
echo "ATTEMPT_3_REQUIRED=NO"
echo "TEST_REMOVAL_OR_MODIFICATION_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_ALLOWED=NO"
echo "NEXT_ACTION=DETERMINE_FROM_GIT_HISTORY_WHETHER_SCHEMA_BOUNDING_COMMIT_WAS_EXPLICITLY_REVERTED_OR_SUPERSEDED"
