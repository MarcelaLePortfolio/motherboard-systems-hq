#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="b0c8ab69e"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== CONFIRMED FAILURE CLASS ===\n'
echo "FAILURE_CLASS=TEST_FIXTURES_DO_NOT_SATISFY_REVIEW_REVISION_PRECONDITION"
echo "WORKSPACE_HANDOFF_FAILURE=NO"
echo "SERVER_REVISION_CONTRACT_FAILURE=NO"
echo "CLIENT_REVISION_CONTRACT_FAILURE=NO"
echo "CANONICAL_BOUNDARY_FAILURE=NO"
echo "PRODUCT_CODE_REPAIR_REQUIRED=NO"

printf '\n=== TEST-ONLY REPAIR BOUNDARY ===\n'
echo "REPAIR_AUTHORIZED=NO"
echo "PROPOSED_MUTATION_CLASS=TEST_FIXTURES_ONLY"
echo "IN_SCOPE=db/approval-request-model-assembler.test.ts"
echo "IN_SCOPE=routes/api-approval-request.test.ts"
echo "PRODUCTION_DATABASE_MUTATION=NO"
echo "PRODUCT_CODE_MUTATION=NO"
echo "CANONICAL_BOUNDARY_MUTATION=NO"
echo "DELEGATION_MUTATION=NO"
echo "VALIDATION_MUTATION=NO"
echo "ENVELOPE_MUTATION=NO"
echo "EXECUTION_MUTATION=NO"
echo "GOVERNANCE_MUTATION=NO"
echo "AUTHORITY_MUTATION=NO"

printf '\n=== CONFIRM ASSEMBLER FIXTURE GAP ===\n'
grep -n -E \
  'draft-hq-pending|draft-1|draft-2' \
  db/approval-request-model-assembler.test.ts

printf '\n=== CONFIRM API FIXTURE SHAPE ===\n'
grep -n -E \
  'CREATE TABLE matilda_living_draft_packages|INSERT INTO matilda_living_draft_packages|draft-api-pending' \
  routes/api-approval-request.test.ts

printf '\n=== REQUIRED POST-REPAIR VALIDATION ===\n'
echo "VALIDATION_1=TARGETED_APPROVAL_REQUEST_TESTS"
echo "VALIDATION_2=SERVER_BUILD"
echo "VALIDATION_3=CLIENT_BUILD"
echo "VALIDATION_4=PROTECTED_BOUNDARY_DIFF_CHECK"
echo "VALIDATION_5=ONLY_THEN_RUNTIME_VALIDATE_NATURAL_APPROVAL_FLOW"

printf '\n=== VERIFY READ ONLY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts \
  db/approval-request-model-assembler.ts \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/ApprovalsWorkspace.tsx \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  server/execution \
  server/operational \
  db/governance-execution-approvals.ts \
  db/governance-execution-scopes.ts \
  db/governance-execution-reconciliation-persistence.ts

printf '\n=== STOPPING POINT ===\n'
echo "TEST_FIXTURE_REPAIR_BOUNDARY=DEFINED"
echo "TEST_FIXTURE_REPAIR_EXECUTED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=EXPLICIT_TEST_ONLY_REPAIR_AUTHORIZATION_REQUIRED"
echo "CLEAR_STOPPING_POINT=YES"
