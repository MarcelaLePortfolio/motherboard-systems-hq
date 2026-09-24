#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="fcf03fe7f"
IMPLEMENTATION_COMMIT="ae71d4cf3"

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
printf ' ENVELOPE GATE VALIDATION ELIGIBILITY — CLOSURE\n'
printf '====================================================\n\n'

echo "IMPLEMENTATION_COMMIT=$IMPLEMENTATION_COMMIT"
echo "RECORD_COMMIT=$EXPECTED_HEAD"
echo "IMPLEMENTATION_STATUS=LANDED"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"

printf '\n=== IMPLEMENTATION COMMIT TARGETS ===\n'
git diff-tree --no-commit-id --name-only -r "$IMPLEMENTATION_COMMIT"

test "$(git diff-tree --no-commit-id --name-only -r "$IMPLEMENTATION_COMMIT" | wc -l | tr -d ' ')" = "6"

for f in "${TARGETS[@]}"; do
  git diff-tree --no-commit-id --name-only -r "$IMPLEMENTATION_COMMIT" | grep -Fxq "$f"
done

printf '\n=== REVALIDATION GATE 1: DIFF CHECK ===\n'
git diff --check "$IMPLEMENTATION_COMMIT^" "$IMPLEMENTATION_COMMIT"

printf '\n=== REVALIDATION GATE 2: TYPECHECK ===\n'
npm run check

printf '\n=== REVALIDATION GATE 3: EXACT VALIDATION READER ===\n'
./node_modules/.bin/tsx --test \
  db/governance-envelope-gate-validation-read-repository.test.ts

printf '\n=== REVALIDATION GATE 4: GATE CONSUMER + ROUTE + ENTRY POINT ===\n'
./node_modules/.bin/tsx --test \
  server/gate/production-envelope-gate-consumer.test.ts \
  server/routes/governance-envelope-gate-route.test.ts \
  server/gate/production-envelope-gate-entry-point.test.ts

printf '\n=== CONTRACT EVIDENCE ===\n'
grep -nE \
  'validation_result_id|delegation_id|package_id|package_version|LIMIT 2|rows.length !== 1|readonly: true|fileMustExist: true' \
  db/governance-envelope-gate-validation-read-repository.ts

grep -nE \
  'load_exact_governance_validation_result|assertEnvelopeCreationEligible|failedClosed|endpoint_authorized: false|invokeProductionEnvelopeGateEntryPoint' \
  server/gate/production-envelope-gate-consumer.ts

grep -nE \
  'load_exact_governance_validation_result|endpoint_authorized: true|envelope_creation_authorized: false|execution_authorized: false|new_authority_introduced: false' \
  server/routes/governance-envelope-gate-route.ts

printf '\n=== CLOSURE CLASSIFICATION ===\n'
echo "EXACT_VALIDATION_LINEAGE_REQUIRED=YES"
echo "IDENTITY=validation_result_id+delegation_id+package_id+package_version"
echo "EXACTLY_ONE_RESULT_REQUIRED=YES"
echo "VALIDATION_PASSED_REQUIRED=YES"
echo "ELIGIBILITY_BEFORE_GATE_PERSISTENCE=YES"
echo "MISSING_FAILS_CLOSED=YES"
echo "WRONG_PACKAGE_FAILS_CLOSED=YES"
echo "WRONG_VERSION_FAILS_CLOSED=YES"
echo "WRONG_DELEGATION_FAILS_CLOSED=YES"
echo "NONPASSED_FAILS_CLOSED=YES"
echo "ENTRY_POINT_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "CLIENT_CHANGE=NO"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_VALIDATION_TO_GATE_TRANSITION=NO"
echo "AUTOMATIC_GATE_CREATION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "DOWNSTREAM_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n====================================================\n'
printf ' VALIDATION → ENVELOPE GATE ELIGIBILITY REPAIR CLOSED\n'
printf '====================================================\n'
echo "CORRIDOR_STATUS=CLOSED"
echo "SUCCESSOR_BOUNDARY=EXPLICIT_OPERATOR_ENVELOPE_GATE_ACTION"
echo "SUCCESSOR_IMPLEMENTATION_AUTHORIZED=NO"
echo "LIVE_GATE_EXECUTION_REQUIRES_SEPARATE_EXPLICIT_OPERATOR_ACTION=YES"

printf '\nENVELOPE_GATE_VALIDATION_ELIGIBILITY_REPAIR=CLOSED\n'
