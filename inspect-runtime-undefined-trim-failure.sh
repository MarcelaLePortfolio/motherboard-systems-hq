#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="ac4d94fba"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== RUNTIME FAILURE CLASSIFICATION ===\n'
echo "MODE=READ_ONLY_INVESTIGATION"
echo "RUNTIME_VALIDATION_STATUS=FAILED_WITH_NEW_ERROR"
echo "PRIOR_ERROR=draft_revision_id_is_required"
echo "OBSERVED_ERROR=Cannot_read_properties_of_undefined_reading_trim"
echo "APPROVAL_DEFECT_CORRIDOR_STATUS=OPEN"
echo "RETRY_APPROVE=NO"
echo "MUTATION_AUTHORIZED=NO"

printf '\n=== FIND TRIM CALLS IN APPROVAL PATH ===\n'
grep -RIn --exclude-dir=node_modules --exclude-dir=dist \
  -E '\.trim\(\)|trim\(' \
  client/src/approvals \
  db/approval-request-model-assembler.ts \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  routes/api-approval-request.ts \
  2>/dev/null || true

printf '\n=== APPROVAL WORKSPACE CALLSITE ===\n'
grep -n -B 12 -A 18 \
  'approveCanonicalPackage' \
  client/src/approvals/ApprovalsWorkspace.tsx || true

printf '\n=== CLIENT API REQUIRETEXT AND APPROVE CONTRACT ===\n'
grep -n -B 8 -A 35 \
  -E 'function requireText|const requireText|approveCanonicalPackage' \
  client/src/approvals/approvalRequestApi.ts || true

printf '\n=== SERVER CANONICAL ROUTE INPUT CONTRACT ===\n'
grep -n -B 10 -A 40 \
  -E 'draft_revision_id|draft_package_id|trim\(' \
  server/routes/matilda-canonical-package-route.ts || true

printf '\n=== CURRENT APPROVAL READ-MODEL REVISION CONTRACT ===\n'
grep -n -B 8 -A 16 \
  -E 'draft_revision_id|createDraftRevisionForApprovalReview' \
  db/approval-request-model-assembler.ts || true

printf '\n=== VERIFY READ ONLY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== STOPPING POINT ===\n'
echo "RUNTIME_FAILURE_CAPTURED=YES"
echo "FAILURE_CALLSITE_NOT_YET_ASSUMED=YES"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "APPROVAL_RETRIED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=CLASSIFY_EXACT_UNDEFINED_TRIM_CALLSITE_FROM_EVIDENCE"
echo "CLEAR_STOPPING_POINT=YES"
