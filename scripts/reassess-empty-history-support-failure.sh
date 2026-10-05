#!/bin/bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="ff2ba1449"
STABLE_RUNTIME="c8b4cf51d"

echo "=== EMPTY-HISTORY SUPPORT FAILURE — STABLE-BASE REASSESSMENT ==="

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

echo "CHECKPOINT=VERIFIED"
echo

echo "=== 1. VERIFY RECOVERED RUNTIME REMAINS STABLE ==="
git diff --quiet "$STABLE_RUNTIME" HEAD -- scripts/utils/ollamaChat.ts
echo "RUNTIME_MATCHES_STABLE=YES"
echo

echo "=== 2. EXACT SUPPORT-REFERENCE PARSE + VALIDATION PATH ==="
nl -ba scripts/utils/ollamaChat.ts | sed -n '680,875p'
echo

echo "=== 3. EXACT EMPTY-HISTORY PROMPT CONTRACT ==="
nl -ba scripts/utils/ollamaChat.ts | sed -n '1125,1170p'
echo

echo "=== 4. EXACT REQUEST / RESPONSE BOUNDARY ==="
grep -n -B50 -A120 \
  -E 'fetch\(|api/generate|OLLAMA_CHAT_OUTPUT_SCHEMA|JSON\.parse|supportSourceReferences' \
  scripts/utils/ollamaChat.ts | tail -900
echo

echo "=== 5. SUPPORT-REFERENCE TEST INVENTORY ==="
git ls-files 'scripts/utils/ollamaChat*.test.ts' | \
  grep -E 'support|source|current-user|selected-context|schema' | \
  sort
echo

echo "=== 6. CURRENT FAIL-CLOSED TEST CONTRACTS ==="
sed -n '1,320p' scripts/utils/ollamaChat.support-source-references.test.ts
echo
sed -n '1,260p' scripts/utils/ollamaChat.support-source-production.test.ts
echo

echo "=== 7. EMPTY-HISTORY REGRESSION TEST ==="
cat scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts
echo

echo "=== 8. SEARCH FOR EXISTING NORMALIZATION / FILTERING PRECEDENT ==="
git grep -n -E \
  'filter\(.*support|supportSourceReferences.*filter|allowedConversationSupportSourceIds|invalid.*support|unsupported.*source|sourceTurnId' \
  HEAD -- scripts/utils server | head -500 || true
echo

echo "=== 9. HISTORY OF SUPPORT VALIDATION ==="
git log --oneline -25 -- \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.support-source-production.test.ts
echo

echo "=== 10. REASSESSMENT BOUNDARY ==="
echo "STABLE_RUNTIME=VERIFIED"
echo "ORIGINAL_EMPTY_HISTORY_FAILURE=REMAINS_UNRESOLVED"
echo "SCHEMA_BOUNDING_ATTEMPTS_FAILED=2"
echo "SCHEMA_BOUNDING_ATTEMPT_3=NOT_STARTED"
echo "CURRENT_TASK=IDENTIFY_DIFFERENT_SOLUTION_CLASS_FROM_EXISTING_RUNTIME_CONTRACT"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "CODE_MUTATION=NONE"
echo "DATABASE_MUTATION=NONE"
echo "COMMIT_PERFORMED=NO"
echo "PUSH_PERFORMED=NO"
