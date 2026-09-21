#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="0d62a6171"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== CONCLUSION ===\n'
echo "RUNTIME_FAILURE_CLASS=CLIENT_RUNTIME_REQUEST_MISSING_DRAFT_REVISION_ID"
echo "FAILING_PATH=request.draft_revision_id_TO_requireText_TO_value.trim"
echo "SERVER_CANONICAL_REQUEST_REACHED=NOT_PROVEN"
echo "APPROVAL_DEFECT_CORRIDOR_STATUS=OPEN"

printf '\n=== VERIFIED EVIDENCE ===\n'
sed -n '179,205p' client/src/approvals/ApprovalsWorkspace.tsx
sed -n '102,113p' client/src/approvals/approvalRequestApi.ts
sed -n '209,234p' client/src/approvals/approvalRequestApi.ts

printf '\n=== NEXT INVESTIGATION ===\n'
echo "QUESTION=WHY_DOES_LIVE_APPROVAL_REQUEST_LACK_DRAFT_REVISION_ID"
echo "CHECK_1=LIVE_APPROVAL_REQUEST_RESPONSE"
echo "CHECK_2=APPROVAL_REQUEST_FETCH_AND_NORMALIZATION_PATH"
echo "CHECK_3=RUNNING_SERVER_AND_CLIENT_VERSION"
echo "APPROVAL_RETRY=NO"
echo "MUTATION_AUTHORIZED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "CLEAR_STOPPING_POINT=YES"
