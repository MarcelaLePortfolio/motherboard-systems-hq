#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="04daa3e01"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== TEST-ONLY CJS REPAIR BOUNDARY ===\n'
echo "FAILURE_CLASS=TEST_FIXTURE_MODULE_FORMAT_INCOMPATIBILITY"
echo "REPAIR_SCOPE=REMOVE_TOP_LEVEL_AWAIT_FROM_TWO_AUTHORIZED_TEST_FIXTURES"
echo "PRODUCT_CODE_MUTATION=NO"
echo "PRODUCTION_DATABASE_MUTATION=NO"
echo "AUTHORITY_MUTATION=NO"

python3 <<'PY'
from pathlib import Path

repairs = {
    Path("db/approval-request-model-assembler.test.ts"): (
        '''const {
  assembleApprovalRequestReadCollection,
  assembleApprovalRequestReadModel,
} = await import("./approval-request-model-assembler");''',
        '''const {
  assembleApprovalRequestReadCollection,
  assembleApprovalRequestReadModel,
} = require("./approval-request-model-assembler");''',
    ),
    Path("routes/api-approval-request.test.ts"): (
        '''const {
  handleApprovalRequestList,
} = await import("./api-approval-request");''',
        '''const {
  handleApprovalRequestList,
} = require("./api-approval-request");''',
    ),
}

for path, (old, new) in repairs.items():
    text = path.read_text()

    if text.count(old) != 1:
        raise SystemExit(
            f"{path}: expected exactly one proven top-level-await import block"
        )

    updated = text.replace(old, new, 1)

    if "await import(" in updated:
        raise SystemExit(
            f"{path}: unexpected additional await import remains"
        )

    path.write_text(updated)

print("STRUCTURAL_TEST_IMPORT_REPAIR=APPLIED")
PY

printf '\n=== VERIFY EXACT TEST-ONLY MUTATION ===\n'
git diff --check -- \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts

git diff -- \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts

printf '\n=== VERIFY TOP-LEVEL AWAIT REMOVED ===\n'
! grep -n 'await import(' \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts

printf '\n=== TARGETED TESTS ===\n'
npx tsx --test \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts

printf '\n=== SERVER BUILD ===\n'
npm run build

printf '\n=== CLIENT BUILD ===\n'
npm --prefix client run build

printf '\n=== VERIFY PROTECTED PRODUCT BOUNDARIES ===\n'
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

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "CJS_TEST_FIXTURE_REPAIR=IMPLEMENTED"
echo "TARGETED_TESTS=PASS"
echo "SERVER_BUILD=PASS"
echo "CLIENT_BUILD=PASS"
echo "PRODUCTION_DATABASE_MUTATED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "CANONICAL_BOUNDARY_CHANGED=NO"
echo "DELEGATION_CHANGED=NO"
echo "VALIDATION_CHANGED=NO"
echo "ENVELOPE_CHANGED=NO"
echo "EXECUTION_CHANGED=NO"
echo "GOVERNANCE_CHANGED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=RUNTIME_VALIDATE_NATURAL_APPROVAL_FLOW"
echo "CLEAR_STOPPING_POINT=YES"
