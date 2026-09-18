#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== PROVEN FAILURE ===\n'
echo "ERROR_CLASS=SQLITE_ERROR"
echo "EXACT_ERROR=no such table: matilda_canonical_packages"
echo "FAILED_HYPOTHESIS_COUNT=1"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "TEST_MUTATION_AUTHORIZED=NO"

printf '\n=== FIND ALL CANONICAL TABLE REFERENCES ===\n'
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'matilda_canonical_packages' \
  server db \
  | head -n 300 || true

printf '\n=== FIND CANONICAL TABLE CREATION ===\n'
grep -RIn -A45 -B15 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'CREATE TABLE IF NOT EXISTS matilda_canonical_packages\|CREATE TABLE matilda_canonical_packages' \
  server db \
  | head -n 360 || true

printf '\n=== FIND WORKFLOW CANONICAL READ PATH ===\n'
grep -RIn -A55 -B25 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'canonical.*package\|Canonical.*Package' \
  server/matilda-chat-workflow.ts \
  server \
  db \
  | head -n 520 || true

printf '\n=== CURRENT FIXTURE SCHEMA INITIALIZATION ===\n'
grep -n -A220 -B30 \
  'database = new Database' \
  "$TEST" \
  | head -n 320 || true

printf '\n=== CURRENT TEST CANONICAL ASSERTION ===\n'
grep -n -A55 -B25 \
  'matilda_canonical_packages' \
  "$TEST" || true

printf '\n=== VERIFY NO NEW MUTATION ===\n'
test -z "$(git diff --cached --name-only)"
git diff --check -- "$TEST"

git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-living-draft-runtime.ts \
  db/atlas-historical-observation-persistence.ts

printf '\n=== CLASSIFICATION ===\n'
echo "DIAGNOSTIC_ONLY=YES"
echo "PROVEN_MISSING_TABLE=matilda_canonical_packages"
echo "MUTATION_APPLIED=NO"
echo "NEXT_ACTION=DETERMINE_WHETHER_FIXTURE_MUST_INITIALIZE_EXISTING_CANONICAL_SCHEMA"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"

printf '\n=== STOP ===\n'
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "TEST_MUTATION_AUTHORIZED=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
