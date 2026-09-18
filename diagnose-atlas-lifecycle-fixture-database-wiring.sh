#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== DIAGNOSTIC BOUNDARY ===\n'
echo "FAILED_HYPOTHESIS_COUNT=1"
echo "CURRENT_FAILURE=SQLITE_ERROR"
echo "KNOWN_RUNTIME_REQUIREMENT=matilda_conversation_turns.interpretation_entry_id"
echo "FIXTURE_CREATES_IEL=YES"
echo "FIXTURE_CREATES_CONVERSATION_TURNS=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "TEST_MUTATION_AUTHORIZED=NO"

printf '\n=== TEST DATABASE SETUP AND REDIRECTION ===\n'
grep -n -A120 -B30 \
  'Database\|main.db\|temporary\|temp\|mkdtemp\|rename\|copyFile\|dbPath\|database\|process.chdir\|cwd' \
  "$TEST" \
  | head -n 420 || true

printf '\n=== TEST SETUP BEFORE RUNTIME REQUIRES ===\n'
sed -n '1,240p' "$TEST"

printf '\n=== TEST SCHEMA / DIRECT SQL REGION ===\n'
sed -n '300,430p' "$TEST"

printf '\n=== CONVERSATION RUNTIME DATABASE BINDING ===\n'
grep -n -A25 -B15 \
  'new Database\|db/main.db\|const sqlite' \
  db/matilda-conversation-runtime.ts \
  | head -n 120 || true

printf '\n=== IEL RUNTIME DATABASE BINDING ===\n'
grep -n -A25 -B15 \
  'new Database\|db/main.db\|const sqlite' \
  db/matilda-interpretation-runtime.ts \
  | head -n 120 || true

printf '\n=== LIVING DRAFT RUNTIME DATABASE BINDING ===\n'
grep -n -A25 -B15 \
  'new Database\|db/main.db\|const sqlite' \
  db/matilda-living-draft-runtime.ts \
  | head -n 120 || true

printf '\n=== DATABASE FILE STATE ===\n'
ls -la db/main.db 2>/dev/null || true
find . -maxdepth 4 \
  \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \) \
  -print | sort

printf '\n=== VERIFY NO NEW MUTATION ===\n'
git diff --check -- "$TEST"
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-living-draft-runtime.ts \
  db/atlas-historical-observation-persistence.ts

printf '\n=== CLASSIFICATION ===\n'
echo "DIAGNOSTIC_ONLY=YES"
echo "FAILED_HYPOTHESIS_COUNT=1"
echo "NEXT_ACTION=CLASSIFY_FIXTURE_DATABASE_WIRING_BEFORE_ANY_MUTATION"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
echo "NO TEST MUTATION / NO PRODUCT MUTATION"
