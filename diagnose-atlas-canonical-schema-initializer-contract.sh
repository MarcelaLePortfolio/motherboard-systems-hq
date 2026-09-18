#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"
RUNTIME="db/matilda-canonical-package-runtime.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== CURRENT CHECKPOINT ===\n'
git rev-parse HEAD
echo "PROVEN_MISSING_TABLE=matilda_canonical_packages"
echo "FAILED_HYPOTHESIS_COUNT=1"
echo "TEST_MUTATION_AUTHORIZED=NO"

printf '\n=== CANONICAL INITIALIZER IMPLEMENTATION ===\n'
grep -n -A180 -B30 \
  'initializeCanonicalPackageSchema' \
  "$RUNTIME" \
  | head -n 280 || true

printf '\n=== CANONICAL RUNTIME DATABASE BINDING ===\n'
grep -n \
  'new Database\|databasePath\|db/main.db\|initializeCanonicalPackageSchema' \
  "$RUNTIME" || true

printf '\n=== PRODUCTION BOOTSTRAP CONTRACT ===\n'
grep -n -A20 -B10 \
  'initializeCanonicalPackageSchema' \
  server/index.ts || true

printf '\n=== TESTS USING INITIALIZER ===\n'
grep -RIn -A15 -B10 \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'initializeCanonicalPackageSchema' \
  db server \
  | head -n 360 || true

printf '\n=== AUTHORITATIVE CANONICAL SCHEMA ===\n'
grep -n -A80 -B15 \
  'CREATE TABLE.*matilda_canonical_packages' \
  "$RUNTIME" || true

printf '\n=== TEMP FIXTURE DATABASE BINDING ===\n'
grep -n -A55 -B25 \
  'database = new Database' \
  "$TEST" || true

printf '\n=== CLASSIFY SAFE RESTORATION PATH ===\n'

if grep -Eq \
  'initializeCanonicalPackageSchema[[:space:]]*\([^)]*(db|sqlite|database|databasePath|path)' \
  "$RUNTIME"; then
  echo "INITIALIZER_ACCEPTS_EXPLICIT_DATABASE_OR_PATH=LIKELY_YES"
  echo "PREFERRED_RESTORATION=CALL_EXISTING_INITIALIZER_AGAINST_TEMP_FIXTURE"
else
  echo "INITIALIZER_ACCEPTS_EXPLICIT_DATABASE_OR_PATH=NOT_PROVEN"
  echo "PREFERRED_RESTORATION=DO_NOT_CALL_DEFAULT_INITIALIZER_UNTIL_BINDING_IS_PROVEN_SAFE"
fi

echo "NO_TEST_MUTATION_PERFORMED=YES"
echo "NO_PRODUCT_MUTATION_PERFORMED=YES"
echo "NEXT_GATE=AUTHORIZE_NARROW_FIXTURE_SCHEMA_RESTORATION_AFTER_CONTRACT_CLASSIFICATION"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"

printf '\n=== VERIFY NO NEW MUTATION ===\n'
test -z "$(git diff --cached --name-only)"
git diff --check -- "$TEST"

git diff --exit-code -- \
  "$RUNTIME" \
  server/index.ts \
  "$TEST"

printf '\n=== STOP ===\n'
echo "TEST_MUTATION_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
