#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="190c210e3"
TEST="scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts"
TARGET="scripts/utils/ollamaChat.ts"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== EMPTY-HISTORY SCHEMA TEST RECONCILIATION ==="
echo "HEAD=$EXPECTED_HEAD"
echo "FUNCTIONAL_MUTATION=NO"
echo "TEST_MUTATION=NO"
echo "DOGFOOD_RETRY=NO"
echo "ATTEMPT_3_STARTED=NO"

echo
echo "=== TRACKING STATUS ==="
if git ls-files --error-unmatch "$TEST" >/dev/null 2>&1; then
  echo "EMPTY_HISTORY_SCHEMA_TEST_TRACKED=YES"
else
  echo "EMPTY_HISTORY_SCHEMA_TEST_TRACKED=NO"
fi

echo
echo "=== TEST PROVENANCE ==="
git status --short -- "$TEST"
git log --all --oneline -- "$TEST" | head -20 || true

echo
echo "=== CURRENT TEST ASSERTIONS ==="
sed -n '1,120p' "$TEST"

echo
echo "=== CURRENT IMPLEMENTATION CONTRACT ==="
grep -n -E \
  'OLLAMA_CHAT_OUTPUT_SCHEMA|buildOllamaChatOutputSchema|allowedConversationSupportSourceIds|conversation_turn' \
  "$TARGET" | head -80 || true

echo
echo "=== AUTHORIZED GROUNDING DIFF ==="
git diff -- "$TARGET"

echo
echo "=== SAFETY ==="
echo "NO_SOURCE_CHANGED=YES"
echo "NO_TEST_CHANGED=YES"
echo "NO_SCHEMA_CHANGED=YES"
echo "NO_FIDELITY_GUARD_CHANGED=YES"
echo "NO_AUTHORITY_CHANGED=YES"
echo "UNRELATED_WORKTREE_PRESERVED=YES"
echo "NEXT_ACTION=CLASSIFY_EMPTY_HISTORY_SCHEMA_TEST_FROM_TRACKING_AND_PROVENANCE_EVIDENCE"
