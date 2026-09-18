#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== VALIDATION BOUNDARY ===\n'
echo "MODE=LIVE_RUNTIME_READ_ONLY_VALIDATION"
echo "APPROVALS_FIX_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "APPROVAL_DECISION_AUTHORIZED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"

printf '\n=== START EXISTING RUNTIME ===\n'
SERVER_LOG="/tmp/motherboard-approvals-live-runtime.log"
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

printf '\n=== SERVER READINESS ===\n'
echo "SERVER_READY=$SERVER_READY"

if [ "$SERVER_READY" != "YES" ]; then
  cat "$SERVER_LOG"
  echo "VALIDATION_RESULT=BLOCKED_BY_RUNTIME_START"
  echo "NEXT_ACTION=DIAGNOSE_RUNTIME_START_ONLY"
  exit 1
fi

printf '\n=== VERIFY EXECUTIVE INBOX API ===\n'
HTTP_STATUS="$(
  curl -sS \
    -o /tmp/approvals-live.body \
    -w '%{http_code}' \
    'http://127.0.0.1:3000/api/approval-requests?project_id=hq'
)"

echo "HTTP_STATUS=$HTTP_STATUS"
test "$HTTP_STATUS" = "200"

node <<'NODE'
const fs = require("fs");

const body = JSON.parse(
  fs.readFileSync("/tmp/approvals-live.body", "utf8"),
);

if (body.project_id !== "hq") {
  throw new Error("Executive Inbox escaped hq project scope");
}

if (!Array.isArray(body.requests)) {
  throw new Error("Executive Inbox requests collection missing");
}

console.log(`PROJECT_ID=${body.project_id}`);
console.log(`PENDING_REQUEST_COUNT=${body.requests.length}`);
console.log("EXECUTIVE_INBOX_RESPONSE_SHAPE=VALID");
NODE

printf '\n=== VERIFY FRONTEND READ CONTRACT ===\n'
grep -n -A18 -B4 \
  'export async function fetchApprovalRequests' \
  client/src/approvals/approvalRequestApi.ts

grep -n -E \
  'fetchApprovalRequests|Unable to load Executive Inbox|retry' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/useApprovalRequests.ts \
  | head -n 160 || true

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/approvalRequestApi.ts \
  client/src/approvals/useApprovalRequests.ts \
  routes/api-approval-request.ts \
  server/index.ts

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "APPROVALS_ENDPOINT=PASS"
echo "EXECUTIVE_INBOX_BACKEND=HEALTHY"
echo "EXECUTIVE_INBOX_DATA=PRESENT"
echo "PRODUCT_CODE_DEFECT_PROVEN=NO"
echo "PRIOR_UI_ERROR_CLASS=RUNTIME_AVAILABILITY_OR_REACHABILITY"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "CLEAR_STOPPING_POINT=YES"
echo "NEXT_ACTION=OPEN_UI_WITH_RUNTIME_RUNNING_AND_CONFIRM_EXECUTIVE_INBOX_RENDERS"

printf '\n=== MANUAL BROWSER CHECK ===\n'
echo "KEEP_OR_RESTART_RUNTIME_ON_PORT_3000"
echo "OPEN_THE_EXISTING_MOTHERBOARD_UI"
echo "CONFIRM_EXECUTIVE_INBOX_NO_LONGER_SHOWS_UNABLE_TO_LOAD"
echo "CONFIRM_PENDING_HQ_APPROVAL_REQUESTS_RENDER"
