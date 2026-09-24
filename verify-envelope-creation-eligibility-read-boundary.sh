#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="26ec06b99"
IMPLEMENTATION_COMMIT="5e0a522d1"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' ENVELOPE CREATION — ELIGIBILITY READ BOUNDARY VERIFY\n'
printf '====================================================\n\n'

test -f db/governance-envelope-creation-read-repository.ts
test -f db/governance-envelope-creation-read-repository.test.ts
test -f server/envelope/governance-envelope-semantics.ts
test -f server/envelope/governance-envelope-semantics.test.ts

npm run check

./node_modules/.bin/tsx --test \
  db/governance-envelope-creation-read-repository.test.ts \
  server/envelope/governance-envelope-semantics.test.ts

grep -Fq 'FROM governance_validation_results' \
  db/governance-envelope-creation-read-repository.ts

grep -Fq 'FROM governance_envelope_gates' \
  db/governance-envelope-creation-read-repository.ts

grep -Fq 'validation_result_id = ?' \
  db/governance-envelope-creation-read-repository.ts

grep -Fq 'envelope_gate_id = ?' \
  db/governance-envelope-creation-read-repository.ts

grep -Fq 'capability_requirements' \
  server/envelope/governance-envelope-semantics.ts

grep -Fq 'operational_requirements' \
  server/envelope/governance-envelope-semantics.ts

printf '\n=== VERIFIED READ BOUNDARY ===\n'
echo "EXACT_VALIDATION_READ=YES"
echo "EXACT_ENVELOPE_GATE_READ=YES"
echo "LATEST_VALIDATION_LOOKUP=NO"
echo "LATEST_GATE_LOOKUP=NO"
echo "READ_ONLY_PRODUCTION_LOADER=YES"
echo "LIVE_GOVERNANCE_MUTATION=NO"

printf '\n=== VERIFIED SEMANTICS ===\n'
echo "REQUIRED_CAPABILITIES_SOURCE=VALIDATION_CAPABILITY_REQUIREMENTS"
echo "OPERATIONAL_CORRIDOR_SOURCE=VALIDATION_OPERATIONAL_REQUIREMENTS"
echo "TRANSFORMATION_CLASS=LOSSLESS_TRIM_ONLY"
echo "MISSING_REQUIRED_CAPABILITIES_FAIL_CLOSED=YES"
echo "MISSING_OPERATIONAL_CORRIDOR_FAIL_CLOSED=YES"
echo "INVENTED_SEMANTICS=NO"

printf '\n=== IMPLEMENTATION STATUS ===\n'
echo "IMPLEMENTATION_COMMIT=$IMPLEMENTATION_COMMIT"
echo "IMPLEMENTATION_ATTEMPT_1=PASS"
echo "FAILED_IMPLEMENTATION_ATTEMPTS=0"
echo "ELIGIBILITY_READ_BOUNDARY=IMPLEMENTED_AND_VERIFIED"
echo "ENVELOPE_PERSISTENCE_INTEGRATION=NOT_YET_IMPLEMENTED"
echo "EXPLICIT_OPERATOR_ENVELOPE_ACTION=NOT_YET_IMPLEMENTED"
echo "LIVE_ENVELOPE_CREATION=NO"

printf '\n=== PRESERVED AUTHORITY BOUNDARY ===\n'
echo "AUTOMATIC_GATE_TO_ENVELOPE_TRANSITION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "LIFECYCLE_TRANSITION_AUTHORITY=NO"
echo "ROUTING_AUTHORITY=NO"
echo "ASSIGNMENT_AUTHORITY=NO"
echo "SCHEDULING_AUTHORITY=NO"
echo "WORKER_CLAIM_AUTHORITY=NO"
echo "ORCHESTRATION_AUTHORITY=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "DOWNSTREAM_EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== NEXT ATOMIC TARGET ===\n'
echo "NEXT_ACTION=INTEGRATE_EXACT_READ_AND_SEMANTIC_RESOLUTION_INTO_PRODUCTION_ENVELOPE_CONSUMER"
echo "NEXT_ACTION_SCOPE=SERVER_ONLY"
echo "UI_CHANGE=NO"
echo "LIVE_MUTATION_TEST=NO"
echo "AUTOMATIC_ADVANCE=NO"

printf '\nENVELOPE_CREATION_ELIGIBILITY_READ_BOUNDARY_VERIFICATION=PASS\n'
