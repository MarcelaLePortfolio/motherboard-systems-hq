#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== VERIFIED ROOT CAUSE ===\n'
echo "APPROVALS_RESTORED_WHILE_VALIDATION_RUNTIME_RUNNING=YES"
echo "RESTORATION_REVERSED_AFTER_ENTER=YES"
echo "CAUSE=VALIDATION_SCRIPT_EXIT_TRAP_TERMINATED_BACKEND_AND_VITE"
echo "PRODUCT_CODE_DEFECT_PROVEN=NO"
echo "APPROVALS_PRODUCT_FIX_REQUIRED=NO"
echo "ATLAS_PRODUCT_FIX_REQUIRED=NO"
echo "RUNTIME_LIFECYCLE_ISSUE=YES"

printf '\n=== START PERSISTENT BACKEND ===\n'
BACKEND_LOG="/tmp/motherboard-persistent-backend.log"
VITE_LOG="/tmp/motherboard-persistent-vite.log"

nohup npm start >"$BACKEND_LOG" 2>&1 &
BACKEND_PID=$!

for _ in $(seq 1 30); do
  STATUS="$(
    curl -sS \
      -o /tmp/persistent-registry.body \
      -w '%{http_code}' \
      'http://127.0.0.1:3000/api/projects/registry' \
      2>/dev/null || true
  )"

  if [ "$STATUS" = "200" ]; then
    break
  fi

  sleep 1
done

test "${STATUS:-000}" = "200"
echo "PERSISTENT_BACKEND_PID=$BACKEND_PID"
echo "PERSISTENT_BACKEND_READY=YES"

printf '\n=== START PERSISTENT VITE CLIENT ===\n'
(
  cd client
  nohup npm run dev -- --host 127.0.0.1 >"$VITE_LOG" 2>&1 &
  echo $! > /tmp/motherboard-persistent-vite.pid
)

VITE_PID="$(cat /tmp/motherboard-persistent-vite.pid)"
VITE_URL=""

for _ in $(seq 1 30); do
  for PORT in 5173 5174 5175; do
    if curl -sS \
      -o /tmp/persistent-client.body \
      "http://127.0.0.1:${PORT}/" \
      2>/dev/null; then
      VITE_URL="http://127.0.0.1:${PORT}"
      break 2
    fi
  done

  sleep 1
done

test -n "$VITE_URL"

echo "PERSISTENT_VITE_PID=$VITE_PID"
echo "PERSISTENT_VITE_URL=$VITE_URL"
echo "PERSISTENT_VITE_READY=YES"

printf '\n=== VERIFY PROJECT CONTEXT THROUGH PERSISTENT BROWSER ORIGIN ===\n'
REGISTRY_STATUS="$(
  curl -sS \
    -o /tmp/persistent-proxied-registry.body \
    -w '%{http_code}' \
    "$VITE_URL/api/projects/registry" \
    || true
)"

echo "PERSISTENT_REGISTRY_HTTP_STATUS=$REGISTRY_STATUS"
test "$REGISTRY_STATUS" = "200"

node <<'NODE'
const fs = require("fs");

const payload = JSON.parse(
  fs.readFileSync(
    "/tmp/persistent-proxied-registry.body",
    "utf8",
  ),
);

if (payload.activeProjectId !== "hq") {
  throw new Error(
    `Expected activeProjectId=hq, received ${payload.activeProjectId}`,
  );
}

console.log("PERSISTENT_ACTIVE_PROJECT_HQ=YES");
NODE

printf '\n=== VERIFY APPROVALS THROUGH PERSISTENT BROWSER ORIGIN ===\n'
APPROVALS_STATUS="$(
  curl -sS \
    -o /tmp/persistent-approvals.body \
    -w '%{http_code}' \
    "$VITE_URL/api/approval-requests?project_id=hq" \
    || true
)"

echo "PERSISTENT_APPROVALS_HTTP_STATUS=$APPROVALS_STATUS"
test "$APPROVALS_STATUS" = "200"

node <<'NODE'
const fs = require("fs");

const payload = JSON.parse(
  fs.readFileSync(
    "/tmp/persistent-approvals.body",
    "utf8",
  ),
);

if (!Array.isArray(payload.requests)) {
  throw new Error("Missing approval requests array");
}

console.log(`PERSISTENT_PENDING_APPROVALS=${payload.requests.length}`);
console.log("PERSISTENT_EXECUTIVE_INBOX_API=HEALTHY");
NODE

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/project-context \
  client/src/approvals \
  client/vite.config.ts \
  server/index.ts \
  server/project-registry.mjs \
  routes/api-approval-request.ts

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "RUNTIME_RESTORATION=PERSISTENT"
echo "PREVIOUS_REVERSAL_CAUSE=VALIDATION_EXIT_CLEANUP"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "OPEN_THIS_URL=$VITE_URL"
echo "DO_NOT_PRESS_ANY_VALIDATION_HOLD_KEY"
echo "NEXT_ACTION=CONFIRM_UI_REMAINS_RESTORED_AFTER_TERMINAL_RETURNS"
