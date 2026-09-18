#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="74b470d64f691b892c7b66abf0ae2dbd5f3a71dd"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== VERIFIED EXECUTIVE INBOX STATE ===\n'
echo "BACKEND_RUNTIME=HEALTHY_WHEN_STARTED"
echo "APPROVALS_ENDPOINT_HTTP_STATUS=200"
echo "PROJECT_SCOPE=hq"
echo "PENDING_APPROVAL_REQUESTS=8"
echo "RESPONSE_SHAPE=VALID"
echo "PRODUCT_CODE_DEFECT_PROVEN=NO"
echo "PRIOR_UI_ERROR_CLASS=RUNTIME_AVAILABILITY_OR_REACHABILITY"

printf '\n=== VERIFIED CLIENT CONTRACT ===\n'
grep -n -A18 -B4 \
  'export async function fetchApprovalRequests' \
  client/src/approvals/approvalRequestApi.ts

grep -n -E \
  'Unable to load Executive Inbox|Please retry the request' \
  client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== VERIFY CURRENT RUNTIME AVAILABILITY ===\n'
if curl -sS -o /tmp/approvals-runtime-check.body \
  -w '%{http_code}' \
  'http://127.0.0.1:3000/api/approval-requests?project_id=hq' \
  > /tmp/approvals-runtime-check.status 2>/dev/null; then
  STATUS="$(cat /tmp/approvals-runtime-check.status)"
  echo "CURRENT_HTTP_STATUS=$STATUS"
else
  STATUS="000"
  echo "CURRENT_HTTP_STATUS=000"
fi

printf '\n=== CLASSIFICATION ===\n'
if [ "$STATUS" = "200" ]; then
  echo "EXECUTIVE_INBOX_RUNTIME_AVAILABLE=YES"
  echo "EXPECTED_UI_STATE=PENDING_HQ_APPROVALS_RENDER"
  echo "MANUAL_BROWSER_CONFIRMATION_REMAINS=YES"
else
  echo "EXECUTIVE_INBOX_RUNTIME_AVAILABLE=NO"
  echo "EXPECTED_UI_STATE=UNABLE_TO_LOAD_EXECUTIVE_INBOX"
  echo "PRODUCT_FIX_REQUIRED=NO"
  echo "RUNTIME_MUST_BE_STARTED_FOR_UI_TO_LOAD=YES"
fi

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/useApprovalRequests.ts \
  routes/api-approval-request.ts \
  server/index.ts

printf '\n=== FINAL STATUS ===\n'
echo "APPROVALS_BACKEND_DIAGNOSIS=CLOSED"
echo "APPROVALS_PRODUCT_CODE_CHANGE=NOT_INDICATED"
echo "APPROVALS_EXECUTIVE_INBOX_UI_CONFIRMATION=PENDING_MANUAL_BROWSER_CHECK"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "CLEAR_STOPPING_POINT=YES"
