#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="07794de15"

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
printf ' ENVELOPE GATE VALIDATION ELIGIBILITY — ATTEMPT 1\n'
printf '====================================================\n\n'

echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "ATTEMPT=1"
echo "TARGET_COUNT=5"
echo "CURRENT_HYPOTHESIS=EXACT_READ_ONLY_VALIDATION_RESULT_ELIGIBILITY_SEAM"

printf '\n=== TARGET BASELINE GUARD ===\n'
test ! -e "$NEW_READER"
echo "EXPECTED_NEW=$NEW_READER"

for f in \
  "$CONSUMER" \
  "$ROUTE" \
  "$CONSUMER_TEST" \
  "$ROUTE_TEST"
do
  test -f "$f"
  test -z "$(git diff -- "$f")"
  echo "TRACKED=$f"
  echo "BLOB=$(git rev-parse HEAD:"$f")"
done

printf '\n=== EXACT EXISTING CONTRACTS ===\n'
echo "--- consumer ---"
sed -n '1,220p' "$CONSUMER"

echo
echo "--- route ---"
sed -n '1,320p' "$ROUTE"

echo
echo "--- consumer test ---"
sed -n '1,260p' "$CONSUMER_TEST"

echo
echo "--- route test ---"
sed -n '1,320p' "$ROUTE_TEST"

printf '\n=== DATABASE ACCESS PATTERN REFERENCES ===\n'
sed -n '1,240p' db/governance-validation-read-repository.ts

printf '\n=== REQUIRED ATTEMPT 1 CONTRACT ===\n'
echo "READER_MODE=READ_ONLY"
echo "READER_IDENTITY=validation_result_id+package_id+package_version+delegation_id"
echo "READER_LIMIT=2"
echo "EXACTLY_ONE_RESULT_REQUIRED=YES"
echo "RETURN_VALIDATION_STATUS=YES"
echo "VALIDATION_STATUS_REQUIRED=VALIDATION_PASSED"
echo "ELIGIBILITY_CHECK_LOCATION=BEFORE_GATE_PERSISTENCE"
echo "MISSING_FAILS_CLOSED=YES"
echo "AMBIGUOUS_FAILS_CLOSED=YES"
echo "IDENTITY_MISMATCH_FAILS_CLOSED=YES"
echo "NONPASSED_FAILS_CLOSED=YES"

printf '\n=== AUTHORITY BOUNDARY ===\n'
echo "ENTRY_POINT_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "CLIENT_CHANGE=NO"
echo "ENVELOPE_CREATION_CHANGE=NO"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_TRANSITION=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== REQUIRED VALIDATION GATES ===\n'
echo "GATE_1=git_diff_check"
echo "GATE_2=npm_run_check"
echo "GATE_3=consumer_tests"
echo "GATE_4=route_tests"
echo "ALL_REQUIRED_BEFORE_COMMIT=YES"

printf '\n=== FAILURE CONTAINMENT ===\n'
echo "RESTORE_ONLY_FIVE_TARGETS=YES"
echo "PRESERVE_UNRELATED_WORKTREE=YES"
echo "GIT_ADD_DOT=PROHIBITED"
echo "MAX_FAILED_ATTEMPTS_PER_HYPOTHESIS=3"

printf '\n=== WORKTREE PRESERVATION ===\n'
git status --short

printf '\nENVELOPE_GATE_VALIDATION_ELIGIBILITY_ATTEMPT_1_GUARD=PASS\n'
