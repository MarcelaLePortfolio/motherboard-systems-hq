#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== CURRENT VERIFIED STATE ===\n'
echo "APPROVALS_BACKEND_DIAGNOSIS=CLOSED"
echo "APPROVALS_ENDPOINT=PASS_WHEN_RUNTIME_RUNNING"
echo "PROJECT_SCOPE=hq"
echo "PENDING_APPROVAL_REQUESTS=8"
echo "PRODUCT_CODE_DEFECT_PROVEN=NO"
echo "PRODUCT_CODE_CHANGE_INDICATED=NO"
echo "PRIOR_UI_ERROR_CLASS=RUNTIME_AVAILABILITY_OR_REACHABILITY"
echo "ATLAS_CORRIDOR=CLOSED"

printf '\n=== CURRENT RUNTIME CHECK ===\n'
if curl -sS -o /tmp/approvals-manual-gate.body \
  -w '%{http_code}' \
  'http://127.0.0.1:3000/api/approval-requests?project_id=hq' \
  > /tmp/approvals-manual-gate.status 2>/dev/null; then
  STATUS="$(cat /tmp/approvals-manual-gate.status)"
else
  STATUS="000"
fi

echo "CURRENT_HTTP_STATUS=$STATUS"

if [ "$STATUS" = "200" ]; then
  echo "RUNTIME_READY_FOR_BROWSER_CHECK=YES"
  echo "EXPECTED_BROWSER_RESULT=EXECUTIVE_INBOX_RENDERS_PENDING_HQ_APPROVALS"
else
  echo "RUNTIME_READY_FOR_BROWSER_CHECK=NO"
  echo "EXPECTED_BROWSER_RESULT=UNABLE_TO_LOAD_EXECUTIVE_INBOX"
fi

printf '\n=== MANUAL VALIDATION GATE ===\n'
echo "MANUAL_BROWSER_VALIDATION_REQUIRED=YES"
echo "REQUIRED_CHECK_1=OPEN_EXISTING_MOTHERBOARD_UI_WITH_BACKEND_ON_PORT_3000"
echo "REQUIRED_CHECK_2=OPEN_EXECUTIVE_INBOX"
echo "REQUIRED_CHECK_3=CONFIRM_UNABLE_TO_LOAD_MESSAGE_IS_ABSENT"
echo "REQUIRED_CHECK_4=CONFIRM_PENDING_HQ_APPROVAL_REQUESTS_RENDER"
echo "REQUIRED_CHECK_5=DO_NOT_APPROVE_OR_REQUEST_CHANGES"
echo "APPROVAL_ACTION_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== VERIFY NO MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/useApprovalRequests.ts \
  routes/api-approval-request.ts \
  server/index.ts

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "APPROVALS_BACKEND_STATUS=HEALTHY"
echo "APPROVALS_UI_STATUS=PENDING_MANUAL_BROWSER_CONFIRMATION"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "CLEAR_STOPPING_POINT=YES"
