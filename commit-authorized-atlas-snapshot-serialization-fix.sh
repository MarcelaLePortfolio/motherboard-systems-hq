#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
WORKFLOW="server/matilda-chat-workflow.ts"
EXPECTED_HEAD="9a5c1c7995fb60a15b79ed141afb125fb420aad3"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

git diff --check -- "$WORKFLOW"
test "$(git diff --name-only -- "$WORKFLOW")" = "$WORKFLOW"

printf '\n=== AUTHORIZED PRODUCT DIFF ===\n'
git diff -- "$WORKFLOW"

git add -- "$WORKFLOW"
test "$(git diff --cached --name-only)" = "$WORKFLOW"

git commit -m "Normalize Atlas historical Living Draft evidence ids"
PRODUCT_HEAD="$(git rev-parse HEAD)"

git push origin "$BRANCH"
git fetch origin "$BRANCH"
test "$(git rev-parse "origin/$BRANCH")" = "$PRODUCT_HEAD"

printf '\n=== PRODUCT COMMIT COMPLETE ===\n'
echo "AUTHORIZED_PRODUCT_PATH=$WORKFLOW"
echo "PRE_HEAD=$EXPECTED_HEAD"
echo "PRODUCT_HEAD=$PRODUCT_HEAD"
echo "REMOTE_HEAD=$(git rev-parse "origin/$BRANCH")"
echo "PRODUCT_COMMIT=COMPLETE"
echo "PRODUCT_PUSH=COMPLETE"
echo "UNRELATED_WORKTREE_DRIFT=PRESERVED"
echo "LIVE_DOGFOOD_EXECUTED=NO"
echo "PRODUCTION_DATABASE_MUTATED=NO"
echo "DESTRUCTIVE_CLEANUP=NO"
echo "AUTHORITY_CHANGE=NO"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "NEXT_ACTION=RESTORE_BOUNDED_LIFECYCLE_VALIDATION_FROM_NEW_STABLE_BASE"
