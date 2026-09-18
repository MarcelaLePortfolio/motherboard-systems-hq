#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== CLASSIFICATION ===\n'
echo "PREVIOUS_DIAGNOSTIC_EXECUTED=NO"
echo "PREVIOUS_FAILURE_CLASS=DIAGNOSTIC_ANCHOR_MISMATCH"
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"

printf '\n=== EXACT INSERTLEDGER REGION ===\n'
LINE="$(
  grep -n 'const insertLedger' "$TEST" |
    head -1 |
    cut -d: -f1
)"

test -n "$LINE"

START=$((LINE - 8))
END=$((LINE + 90))

if [ "$START" -lt 1 ]; then
  START=1
fi

sed -n "${START},${END}p" "$TEST"

printf '\n=== NUMBERED INSERTLEDGER REGION ===\n'
nl -ba "$TEST" |
  sed -n "${START},${END}p"

printf '\n=== STRUCTURAL TOKENS ===\n'
grep -n -A90 -B8 -E \
  'const insertLedger|database\.prepare|insertLedger\.run|const backfillEntry|createMatildaConversation' \
  "$TEST" || true

printf '\n=== VERIFY AUTHORIZED TEST PRESERVED ===\n'
git diff --check -- "$TEST"
git status --short -- "$TEST"

printf '\n=== VERIFY PRODUCT BOUNDARIES ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== STOP ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=TARGET_EXACT_INSERTLEDGER_SYNTAX_FROM_PRINTED_REGION"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
