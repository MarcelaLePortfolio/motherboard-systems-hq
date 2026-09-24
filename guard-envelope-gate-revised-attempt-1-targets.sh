#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="d58ded04a"

TARGETS=(
  "db/governance-envelope-gate-validation-read-repository.ts"
  "db/governance-envelope-gate-validation-read-repository.test.ts"
  "server/gate/production-envelope-gate-consumer.ts"
  "server/gate/production-envelope-gate-consumer.test.ts"
  "server/routes/governance-envelope-gate-route.ts"
  "server/routes/governance-envelope-gate-route.test.ts"
)

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' ENVELOPE GATE — REVISED ATTEMPT 1 TARGET GUARD\n'
printf '====================================================\n\n'

echo "CURRENT_HEAD=$EXPECTED_HEAD"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "HYPOTHESIS=EXTRACT_NARROW_EXACT_VALIDATION_RESULT_READ_PRIMITIVE_AND_REUSE_LIFECYCLE_ELIGIBILITY_SEMANTICS"
echo "REVISED_HYPOTHESIS_ATTEMPT=1"
echo "IMPLEMENTATION_PERFORMED=NO"
echo "TARGET_COUNT=6"

printf '\n=== TARGET BASELINE ===\n'

for f in \
  "server/gate/production-envelope-gate-consumer.ts" \
  "server/gate/production-envelope-gate-consumer.test.ts" \
  "server/routes/governance-envelope-gate-route.ts" \
  "server/routes/governance-envelope-gate-route.test.ts"
do
  test -f "$f"
  test -z "$(git status --porcelain -- "$f")"
  echo "TRACKED_TARGET_CLEAN=$f"
  echo "BASELINE_BLOB_$f=$(git rev-parse "HEAD:$f")"
done

for f in \
  "db/governance-envelope-gate-validation-read-repository.ts" \
  "db/governance-envelope-gate-validation-read-repository.test.ts"
do
  test ! -e "$f"
  test -z "$(git status --porcelain -- "$f")"
  echo "EXPECTED_NEW_TARGET_ABSENT=$f"
done

printf '\n=== FIXED ATOMIC TARGET SET ===\n'
printf '%s\n' "${TARGETS[@]}"

printf '\n=== IMPLEMENTATION CONTRACT ===\n'
echo "READ_PRIMITIVE=EXACT_READ_ONLY_VALIDATION_RESULT"
echo "IDENTITY=validation_result_id+delegation_id+package_id+package_version"
echo "QUERY_LIMIT=2"
echo "EXACTLY_ONE_REQUIRED=YES"
echo "RETURN_VALIDATION_STATUS=YES"
echo "CONSUMER_OPTIONAL_LOADER=YES"
echo "DEFAULT_READONLY_LOADER=YES"
echo "ROUTE_DEPENDENCY_THREADING=YES"
echo "ELIGIBILITY_BEFORE_GATE_PERSISTENCE=YES"
echo "REUSE_EXISTING_LIFECYCLE_ELIGIBILITY_SEMANTICS=YES"
echo "DUPLICATE_VALIDATION_STATUS_RULE=NO"

printf '\n=== EXCLUDED CHANGES ===\n'
echo "ENTRY_POINT_CHANGE=NO"
echo "ENTRY_POINT_AUTHORITY_FLAGS_CHANGE=NO"
echo "GOVERNANCE_RUNTIME_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "CLIENT_CHANGE=NO"
echo "EXECUTION_READ_REPOSITORY_CHANGE=NO"
echo "MISSION_READ_REPOSITORY_CHANGE=NO"

printf '\n=== SUCCESS CONTRACT ===\n'
echo "MISSING_VALIDATION_RESULT_FAILS_CLOSED=YES"
echo "AMBIGUOUS_VALIDATION_RESULT_FAILS_CLOSED=YES"
echo "WRONG_PACKAGE_FAILS_CLOSED=YES"
echo "WRONG_VERSION_FAILS_CLOSED=YES"
echo "WRONG_DELEGATION_FAILS_CLOSED=YES"
echo "NONPASSED_VALIDATION_FAILS_CLOSED=YES"
echo "EXACT_VALIDATION_PASSED_ALLOWS_ONE_GATE_PERSISTENCE=YES"
echo "ROUTE_THREADS_LOADER_WITHOUT_NEW_AUTHORITY=YES"

printf '\n=== FAILURE CONTAINMENT ===\n'
echo "CURRENT_REVISED_HYPOTHESIS_FAILED_ATTEMPTS=0"
echo "MAX_FAILED_ATTEMPTS_BEFORE_REVERT=3"
echo "ON_FAILURE=RESTORE_ONLY_SIX_ATTEMPT_TARGETS"
echo "PRESERVE_UNRELATED_WORKTREE=YES"
echo "STAGE_ONLY_EXPLICIT_TARGETS=YES"
echo "GIT_ADD_DOT=PROHIBITED"
echo "SPECULATIVE_PATCH_LAYERING=PROHIBITED"

printf '\n=== AUTHORITY BOUNDARY ===\n'
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_VALIDATION_TO_GATE_TRANSITION=NO"
echo "AUTOMATIC_GATE_CREATION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "DOWNSTREAM_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== PRESERVED UNRELATED WORKTREE COUNT ===\n'
git status --short | wc -l | tr -d ' '

printf '\n=== NEXT ACTION ===\n'
echo "NEXT_ACTION=BEGIN_REVISED_HYPOTHESIS_ATOMIC_ATTEMPT_1"
echo "IMPLEMENTATION_PERFORMED=NO"

printf '\nREVISED_ENVELOPE_GATE_ATTEMPT_1_TARGET_GUARD=PASS\n'
