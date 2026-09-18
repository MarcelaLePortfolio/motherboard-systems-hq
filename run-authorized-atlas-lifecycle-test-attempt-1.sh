#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

printf '\n=== VERIFY AUTHORIZED BASELINE ===\n'
git fetch origin "$BRANCH"

printf 'LOCAL_HEAD='
git rev-parse --short=9 HEAD
printf 'REMOTE_HEAD='
git rev-parse --short=9 "origin/$BRANCH"
printf 'RELATIONSHIP='
git rev-list --left-right --count "HEAD...origin/$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

printf '\n=== EXECUTE AUTHORIZED TEST-ONLY ATTEMPT 1 ===\n'
bash -n implement-authorized-atlas-lifecycle-test-attempt-1.sh
./implement-authorized-atlas-lifecycle-test-attempt-1.sh
STATUS=$?

printf '\n=== ATTEMPT EXIT STATUS ===\n'
printf 'STATUS=%s\n' "$STATUS"

printf '\n=== VERIFY AUTHORIZED TEST IS THE ONLY PRODUCT MUTATION ===\n'
git status --short -- "$TEST"

PRODUCT_DIFF="$(
  git diff --name-only -- \
    server \
    db \
    client |
  grep -v '^server/matilda-chat-workflow.explicit-target.integration.test.ts$' \
  || true
)"
test -z "$PRODUCT_DIFF"

printf '\n=== VERIFY PROTECTED PRODUCT BOUNDARIES ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
git diff --cached --name-status
test -z "$(git diff --cached --name-only)"

printf '\n=== CLASSIFICATION ===\n'
echo "AUTHORIZED_TEST_ONLY_ATTEMPT_1_EXECUTED=YES"
echo "ATLAS_LIFECYCLE_VALIDATION=LOCAL_ONLY"
echo "AUTHORIZED_PRODUCT_PATH=$TEST"
echo "PRODUCT_CODE_CHANGE=NO"
echo "LIVE_DOGFOOD_EXECUTION=NO"
echo "PRODUCTION_DATABASE_MUTATION=NO"
echo "DESTRUCTIVE_CLEANUP=NO"
echo "AUTHORITY_CHANGE=NO"
echo "CLEAR_STOPPING_POINT=YES"
echo "SAFE_TO_STOP_HERE=YES"
echo "NEXT_GATE=TEST_COMMIT_AND_PUSH_AUTHORIZATION"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"

printf '\n=== STOP ===\n'
echo "NO TEST COMMIT / NO TEST PUSH"
