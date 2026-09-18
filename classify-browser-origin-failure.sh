#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== VERIFIED DIAGNOSIS ===\n'
echo "SERVER_PROJECT_REGISTRY=HEALTHY"
echo "SERVER_ACTIVE_PROJECT=hq"
echo "PROJECT_CONTEXT_PROVIDER=WIRED"
echo "PROJECT_REGISTRY_FETCH=SAME_ORIGIN_RELATIVE"
echo "SERVER_PORT_3000_ROOT=NOT_UI_ORIGIN"
echo "VITE_API_PROXY_TARGET=http://localhost:3000"
echo "PRODUCT_FIX_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== START BACKEND ===\n'
SERVER_LOG="/tmp/motherboard-browser-validation-server.log"
VITE_LOG="/tmp/motherboard-browser-validation-vite.log"

: > "$SERVER_LOG"
: > "$VITE_LOG"

npm start >"$SERVER_LOG" 2>&1 &
SERVER_PID=$!

VITE_PID=""

cleanup() {
  if [ -n "${VITE_PID:-}" ] && kill -0 "$VITE_PID" 2>/dev/null; then
    kill "$VITE_PID" 2>/dev/null || true
    wait "$VITE_PID" 2>/dev/null || true
  fi

  if kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

for _ in $(seq 1 30); do
  STATUS="$(
    curl -sS \
      -o /tmp/browser-validation-registry.body \
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
echo "BACKEND_READY=YES"

node <<'NODE'
const fs = require("fs");

const payload = JSON.parse(
  fs.readFileSync(
    "/tmp/browser-validation-registry.body",
    "utf8",
  ),
);

if (payload.activeProjectId !== "hq") {
  throw new Error(
    `Expected activeProjectId=hq, received ${payload.activeProjectId}`,
  );
}

console.log("BACKEND_ACTIVE_PROJECT_HQ=YES");
NODE

printf '\n=== START VITE CLIENT ===\n'
(
  cd client
  npm run dev -- --host 127.0.0.1
) >"$VITE_LOG" 2>&1 &
VITE_PID=$!

VITE_URL=""

for _ in $(seq 1 30); do
  for PORT in 5173 5174 5175; do
    if curl -sS \
      -o /tmp/browser-validation-client.body \
      "http://127.0.0.1:${PORT}/" \
      2>/dev/null; then
      VITE_URL="http://127.0.0.1:${PORT}"
      break 2
    fi
  done

  if ! kill -0 "$VITE_PID" 2>/dev/null; then
    break
  fi

  sleep 1
done

if [ -z "$VITE_URL" ]; then
  echo "VITE_READY=NO"
  cat "$VITE_LOG"
  exit 1
fi

echo "VITE_READY=YES"
echo "VITE_URL=$VITE_URL"

printf '\n=== PROVE PROJECT REGISTRY THROUGH BROWSER ORIGIN ===\n'
PROXY_STATUS="$(
  curl -sS \
    -o /tmp/browser-validation-proxy-registry.body \
    -w '%{http_code}' \
    "$VITE_URL/api/projects/registry" \
    || true
)"

echo "VITE_PROXY_REGISTRY_HTTP_STATUS=$PROXY_STATUS"
test "$PROXY_STATUS" = "200"

node <<'NODE'
const fs = require("fs");

const payload = JSON.parse(
  fs.readFileSync(
    "/tmp/browser-validation-proxy-registry.body",
    "utf8",
  ),
);

if (payload.activeProjectId !== "hq") {
  throw new Error(
    `Expected proxied activeProjectId=hq, received ${payload.activeProjectId}`,
  );
}

console.log("VITE_PROXY_ACTIVE_PROJECT_HQ=YES");
NODE

printf '\n=== PROVE APPROVALS THROUGH BROWSER ORIGIN ===\n'
APPROVALS_STATUS="$(
  curl -sS \
    -o /tmp/browser-validation-approvals.body \
    -w '%{http_code}' \
    "$VITE_URL/api/approval-requests?project_id=hq" \
    || true
)"

echo "VITE_PROXY_APPROVALS_HTTP_STATUS=$APPROVALS_STATUS"
test "$APPROVALS_STATUS" = "200"

node <<'NODE'
const fs = require("fs");

const payload = JSON.parse(
  fs.readFileSync(
    "/tmp/browser-validation-approvals.body",
    "utf8",
  ),
);

if (!Array.isArray(payload.requests)) {
  throw new Error(
    "Expected approval response requests array",
  );
}

console.log(
  `PENDING_REQUEST_COUNT=${payload.requests.length}`,
);
console.log("VITE_PROXY_EXECUTIVE_INBOX_API_READY=YES");
NODE

printf '\n=== MANUAL BROWSER CHECK ===\n'
echo "OPEN_EXACT_URL=$VITE_URL"
echo "EXPECTED_PROJECT_CONTEXT=Motherboard Systems HQ"
echo "EXPECTED_PROJECT_REGISTRY_UNAVAILABLE=ABSENT"
echo "OPEN_EXECUTIVE_INBOX"
echo "EXPECTED_UNABLE_TO_LOAD_EXECUTIVE_INBOX=ABSENT"
echo "EXPECTED_PENDING_HQ_APPROVAL_REQUESTS=RENDER"
echo "DO_NOT_CLICK_APPROVE"
echo "DO_NOT_REQUEST_CHANGES"
echo
echo "Keep this command running while checking the browser."
echo "Press Enter only AFTER the browser check."
read -r

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/project-context \
  client/src/main.tsx \
  client/src/App.tsx \
  client/src/shell \
  client/src/approvals \
  client/vite.config.ts \
  server/index.ts \
  server/project-registry.mjs \
  routes/api-approval-request.ts

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "SERVER_REGISTRY=HEALTHY"
echo "SERVER_ACTIVE_PROJECT_HQ=PROVEN"
echo "VITE_BROWSER_ORIGIN=HEALTHY"
echo "VITE_PROJECT_REGISTRY_PROXY=PROVEN"
echo "VITE_APPROVALS_PROXY=PROVEN"
echo "PRODUCT_CODE_DEFECT_PROVEN=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "MANUAL_BROWSER_RESULT=AWAITING_USER_OBSERVATION"
echo "CLEAR_STOPPING_POINT=YES"
echo "NEXT_ACTION=REPORT_EXACT_BROWSER_RESULT"
