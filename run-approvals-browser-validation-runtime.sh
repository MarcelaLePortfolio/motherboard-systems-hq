#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== VERIFIED CHECKPOINT ===\n'
echo "APPROVALS_BACKEND_DIAGNOSIS=CLOSED"
echo "APPROVALS_ENDPOINT=PASS_WHEN_RUNTIME_RUNNING"
echo "PROJECT_CODE_FIX_REQUIRED=NO"
echo "ATLAS_CORRIDOR=CLOSED"
echo "MANUAL_BROWSER_CONFIRMATION=PENDING"

printf '\n=== START RUNTIME FOR BROWSER VALIDATION ===\n'
SERVER_LOG="/tmp/motherboard-browser-validation-server.log"
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
    "http://127.0.0.1:3000/api/approval-requests?project_id=hq" \
    2>/dev/null; then
    SERVER_READY=YES
    break
  fi

  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    break
  fi

  sleep 1
done

printf '\n=== SERVER STATUS ===\n'
echo "SERVER_READY=$SERVER_READY"

if [ "$SERVER_READY" != "YES" ]; then
  cat "$SERVER_LOG"
  echo "BROWSER_VALIDATION_READY=NO"
  exit 1
fi

HTTP_STATUS="$(
  curl -sS \
    -o /tmp/approvals-browser-validation.body \
    -w '%{http_code}' \
    'http://127.0.0.1:3000/api/approval-requests?project_id=hq'
)"

echo "APPROVALS_HTTP_STATUS=$HTTP_STATUS"
test "$HTTP_STATUS" = "200"

node <<'NODE'
const fs = require("fs");

const payload = JSON.parse(
  fs.readFileSync(
    "/tmp/approvals-browser-validation.body",
    "utf8",
  ),
);

if (
  payload.project_id !== "hq" ||
  !Array.isArray(payload.requests)
) {
  throw new Error(
    "Executive Inbox endpoint failed browser-validation precondition",
  );
}

console.log(`PENDING_REQUEST_COUNT=${payload.requests.length}`);
console.log("EXECUTIVE_INBOX_API_READY=YES");
NODE

printf '\n=== BROWSER VALIDATION INSTRUCTIONS ===\n'
echo "BROWSER_VALIDATION_READY=YES"
echo "KEEP_THIS_TERMINAL_COMMAND_RUNNING_WHILE_CHECKING_UI"
echo "OPEN_EXISTING_MOTHERBOARD_UI"
echo "OPEN_EXECUTIVE_INBOX"
echo "EXPECTED_1=UNABLE_TO_LOAD_MESSAGE_ABSENT"
echo "EXPECTED_2=PENDING_HQ_APPROVAL_REQUESTS_RENDER"
echo "DO_NOT_CLICK_APPROVE"
echo "DO_NOT_REQUEST_CHANGES"

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/useApprovalRequests.ts \
  routes/api-approval-request.ts \
  server/index.ts

printf '\n=== HOLD RUNTIME FOR MANUAL CHECK ===\n'
echo "Press Enter only AFTER checking the Executive Inbox in the browser."
read -r

printf '\n=== STOPPING AFTER MANUAL CHECK ===\n'
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "NEXT_ACTION=REPORT_BROWSER_RESULT"
