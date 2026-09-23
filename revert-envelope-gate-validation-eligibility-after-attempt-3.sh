#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="c400800c6"

NEW_READER="db/governance-envelope-gate-read-repository.ts"
CONSUMER="server/gate/production-envelope-gate-consumer.ts"
ROUTE="server/routes/governance-envelope-gate-route.ts"
CONSUMER_TEST="server/gate/production-envelope-gate-consumer.test.ts"
ROUTE_TEST="server/routes/governance-envelope-gate-route.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' ENVELOPE GATE ELIGIBILITY — RESET AFTER ATTEMPT 3\n'
printf '====================================================\n\n'

echo "HYPOTHESIS=EXACT_READ_ONLY_VALIDATION_RESULT_ELIGIBILITY_SEAM"
echo "FAILED_ATTEMPTS=3"
echo "ATTEMPT_1_FAILURE=WHITESPACE_SENSITIVE_IMPORT_ANCHOR"
echo "ATTEMPT_2_FAILURE=GENERATED_TRAILING_WHITESPACE"
echo "ATTEMPT_3_FAILURE=MISSING_REQUIRED_ENDPOINT_AUTHORIZED_FALSE"
echo "PATCH_FORWARD=PROHIBITED"
echo "RESET_TO_STABLE_BASE=REQUIRED"

git restore --staged --worktree -- \
  "$CONSUMER" \
  "$ROUTE" \
  "$CONSUMER_TEST" \
  "$ROUTE_TEST" 2>/dev/null || true

rm -f "$NEW_READER"

test ! -e "$NEW_READER"
test -z "$(git diff -- "$CONSUMER")"
test -z "$(git diff -- "$ROUTE")"
test -z "$(git diff -- "$CONSUMER_TEST")"
test -z "$(git diff -- "$ROUTE_TEST")"

test "$(git rev-parse HEAD:"$CONSUMER")" = "41810bffa279f07e73e793f75cfda262c2f49b9a"
test "$(git rev-parse HEAD:"$ROUTE")" = "da7fc3757372d62b88b62a8a5b0b9390568efbe1"
test "$(git rev-parse HEAD:"$CONSUMER_TEST")" = "1b0e50b290e04e0e3dbfc9504942aef757abb47e"
test "$(git rev-parse HEAD:"$ROUTE_TEST")" = "a76802260b13e17e6c936ac965ca348ade5c1bc6"

printf '\n=== VERIFIED STABLE TARGET STATE ===\n'
echo "HEAD=$EXPECTED_HEAD"
echo "NEW_READER=ABSENT"
echo "CONSUMER=RESTORED"
echo "ROUTE=RESTORED"
echo "CONSUMER_TEST=RESTORED"
echo "ROUTE_TEST=RESTORED"
echo "UNRELATED_WORKTREE=PRESERVED"

printf '\n=== REASSESSMENT BOUNDARY ===\n'
echo "ORIGINAL_HYPOTHESIS_RETRY=BLOCKED"
echo "NEXT_APPROACH_MUST_BE_DIFFERENT_AND_CLEANER=YES"
echo "KNOWN_REQUIRED_RESULT_FLAG=endpoint_authorized:false"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== WORKTREE ===\n'
git status --short

printf '\nENVELOPE_GATE_ELIGIBILITY_STABLE_BASE_RESTORED=YES\n'
