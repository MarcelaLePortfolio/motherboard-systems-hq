#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== INVESTIGATION BOUNDARY ===\n'
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "MODE=DIAGNOSTIC_ONLY"
echo "APPROVALS_FIX_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== VERIFY APPROVALS CONTRACT ===\n'
grep -n -A18 -B8 \
  'fetch(' \
  client/src/approvals/approvalRequestApi.ts \
  | head -n 180 || true

grep -n -A40 -B10 \
  'handleApprovalRequestList' \
  routes/api-approval-request.ts || true

grep -n \
  'app.use("/api/approval-requests", approvalRequestRouter)' \
  server/index.ts

printf '\n=== START EXISTING SERVER TEMPORARILY ===\n'
SERVER_LOG="/tmp/motherboard-approvals-runtime.log"
: > "$SERVER_LOG"

npm start >"$SERVER_LOG" 2>&1 &
SERVER_PID=$!

cleanup() {
  if kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

SERVER_READY=NO
for _ in $(seq 1 30); do
  if curl -sS -o /dev/null \
    "http://127.0.0.1:3000/" 2>/dev/null; then
    SERVER_READY=YES
    break
  fi

  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    break
  fi

  sleep 1
done

printf '\n=== SERVER LOG ===\n'
cat "$SERVER_LOG"

printf '\n=== SERVER READINESS ===\n'
echo "SERVER_READY=$SERVER_READY"

if [ "$SERVER_READY" = "YES" ]; then
  printf '\n=== EXACT EXECUTIVE INBOX ENDPOINT ===\n'

  HTTP_STATUS="$(
    curl -sS \
      -o /tmp/approvals-hq.body \
      -w '%{http_code}' \
      'http://127.0.0.1:3000/api/approval-requests?project_id=hq'
  )"

  echo "HTTP_STATUS=$HTTP_STATUS"
  printf 'RESPONSE_BODY='
  cat /tmp/approvals-hq.body
  printf '\n'

  printf '\n=== CLASSIFICATION ===\n'
  if [ "$HTTP_STATUS" = "200" ]; then
    echo "APPROVALS_ENDPOINT=PASS"
    echo "EXECUTIVE_INBOX_READ_PATH=HEALTHY_WHEN_RUNTIME_IS_AVAILABLE"
    echo "CURRENT_UI_ERROR_CLASS=RUNTIME_AVAILABILITY_OR_REACHABILITY"
    echo "PRODUCT_CODE_DEFECT_PROVEN=NO"
    echo "NEXT_ACTION=RECHECK_EXECUTIVE_INBOX_WITH_RUNTIME_RUNNING"
  else
    echo "APPROVALS_ENDPOINT=FAIL"
    echo "EXECUTIVE_INBOX_FAILURE=REPRODUCED_SERVER_SIDE"
    echo "PRODUCT_CODE_DEFECT_PROVEN=UNDETERMINED"
    echo "NEXT_ACTION=DIAGNOSE_ONLY_THIS_EXACT_ENDPOINT_FAILURE"
  fi
else
  printf '\n=== CLASSIFICATION ===\n'
  echo "APPROVALS_ENDPOINT=NOT_TESTABLE"
  echo "SERVER_START=FAILED_OR_NOT_READY"
  echo "PRODUCT_CODE_DEFECT_PROVEN=NO"
  echo "NEXT_ACTION=DIAGNOSE_ONLY_SERVER_START_FAILURE"
fi

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/useApprovalRequests.ts \
  routes/api-approval-request.ts \
  server/index.ts

printf '\n=== STOP ===\n'
echo "APPROVALS_FIX_EXECUTED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "CLEAR_STOPPING_POINT=YES"
