#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

printf '\n=== VERIFY AUTHORIZATION BOUNDARY ===\n'
echo "FIXTURE_LOCAL_CANONICAL_SCHEMA_RESTORATION_AUTHORIZED=YES"
echo "AUTHORIZED_PATH_ONLY=$TEST"
echo "PRODUCT_CODE_CHANGE_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== RUN AUTHORIZED RESTORATION ===\n'
./implement-authorized-atlas-fixture-canonical-schema-restoration.sh

printf '\n=== VERIFY AUTHORIZED TEST DIFF ===\n'
git diff --check -- "$TEST"
git status --short -- "$TEST"

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== STOP ===\n'
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "PRODUCT_COMMIT_AUTHORIZED=NO"
echo "PRODUCT_PUSH_AUTHORIZED=NO"
echo "NO TEST COMMIT / NO TEST PUSH"
