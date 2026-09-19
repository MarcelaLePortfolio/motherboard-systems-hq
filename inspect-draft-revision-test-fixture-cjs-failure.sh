#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="8e63a7ea9"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== FAILURE CLASSIFICATION ===\n'
echo "TEST_FIXTURE_REPAIR_VALIDATED=NO"
echo "TARGETED_TESTS=FAIL"
echo "FAILURE_CLASS=TEST_FIXTURE_MODULE_FORMAT_INCOMPATIBILITY"
echo "FAILURE_DETAIL=TOP_LEVEL_AWAIT_NOT_SUPPORTED_WITH_CJS_OUTPUT"
echo "PRODUCT_RUNTIME_FAILURE=NO"
echo "DRAFT_REVISION_RUNTIME_FAILURE=NOT_PROVEN"
echo "APPROVAL_HANDOFF_FAILURE=NOT_PROVEN"
echo "SERVER_BUILD_RUN=NO"
echo "CLIENT_BUILD_RUN=NO"
echo "ATTEMPT_COUNT_FOR_THIS_NEW_HYPOTHESIS=1"

printf '\n=== CURRENT TEST IMPORT STRUCTURE ===\n'
grep -n -C 8 -E \
  'process\.chdir|await import|assembleApprovalRequestRead|handleApprovalRequestList|after\(' \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts || true

printf '\n=== MODULE CONFIGURATION ===\n'
node -e '
const fs = require("fs");
for (const p of ["package.json","tsconfig.json"]) {
  console.log(`--- ${p} ---`);
  console.log(fs.readFileSync(p, "utf8"));
}
'

printf '\n=== NEARBY TEST PATTERNS ===\n'
grep -R -n -E \
  'process\.chdir\(|await import\(|before\(|beforeEach\(|createRequire\(|better-sqlite3' \
  db/*.test.ts routes/*.test.ts 2>/dev/null | head -n 240 || true

printf '\n=== VERIFY AUTHORIZED TEST FILES ARE THE ONLY SUBJECT OF THIS FAILURE ===\n'
git diff --check -- \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts

printf '\n=== VERIFY PROTECTED PRODUCT BOUNDARIES UNCHANGED ===\n'
git diff --exit-code -- \
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
echo "CJS_FAILURE_INVESTIGATION=COMPLETE"
echo "MUTATION_EXECUTED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=DEFINE_TEST_ONLY_REPAIR_THAT_AVOIDS_TOP_LEVEL_AWAIT"
echo "CLEAR_STOPPING_POINT=YES"
