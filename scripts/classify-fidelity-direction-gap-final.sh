#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="9042dc442"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "=== PACKAGE SEMANTICS FIDELITY — FINAL CLASSIFICATION ==="
echo
echo "SOURCE_EVIDENCE:"
echo "- operationTerms extracts the requested operation."
echo "- remove maps only to removal-direction semantic terms."
echo "- restore/restored are not accepted semantic equivalents for remove."
echo "- preservesOperation requires expectedOutcome to contain a semantic equivalent of the requested operation."
echo "- the live expectedOutcome 'Canonical Package visibility restored' therefore does not preserve remove."
echo "- the guard rejected the response exactly as designed."
echo
echo "FIDELITY_GUARD_DIRECTION_BEHAVIOR=SUFFICIENT_FOR_CAPTURED_FAILURE"
echo "FIDELITY_GUARD_FALSE_ACCEPTANCE=NO"
echo "FIDELITY_GUARD_DEFECT_ESTABLISHED=NO"
echo "FIDELITY_GUARD_CHANGE_JUSTIFIED=NO"
echo
echo "LIVE_FAILURE_CLASS=UPSTREAM_MODEL_GENERATION_DIRECTION_INVERSION"
echo "REQUESTED_DIRECTION=REMOVE"
echo "MODEL_GENERATED_DIRECTION=RESTORE"
echo "EXISTING_GUARD_RESULT=CORRECT_FAIL_CLOSED"
echo
echo "NEXT_SOLUTION_BOUNDARY=PACKAGE_SEMANTICS_GENERATION_GROUNDING"
echo "REQUIRED_PROPERTY=MODEL_AUTHORED_EXPECTEDOUTCOME_MUST_PRESERVE_CURRENT_REQUEST_OPERATION_AND_DIRECTION"
echo "PRESERVATION_CONSTRAINT_RULE=RUNTIME_FUNCTIONALITY_AND_AUTHORITY_PRESERVATION_MUST_REMAIN_CONSTRAINTS_NOT_BE_RECAST_AS_VISIBILITY_OUTCOME"
echo
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DOGFOOD_RETRY=NO"
echo "VALIDATOR_RELAXATION=NO"
echo "PARSER_CHANGE=NO"
echo "SCHEMA_CHANGE=NO"
echo "AUTHORITY_MODEL_CHANGE=NO"
echo
echo "NEXT_ACTION=REQUEST_EXPLICIT_AUTHORIZATION_FOR_NARROW_PACKAGE_SEMANTICS_GENERATION_GROUNDING_IMPLEMENTATION"
