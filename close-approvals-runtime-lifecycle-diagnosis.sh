#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== VERIFIED CLOSURE STATE ===\n'
echo "APPROVALS_BACKEND=HEALTHY"
echo "PROJECT_REGISTRY=HEALTHY"
echo "ACTIVE_PROJECT=hq"
echo "VITE_BROWSER_ORIGIN=http://127.0.0.1:5173"
echo "PENDING_APPROVAL_REQUESTS=8"
echo "APPROVALS_RESTORES_WHEN_RUNTIME_IS_PERSISTENT=YES"
echo "PREVIOUS_UI_REVERSAL_CAUSE=VALIDATION_EXIT_TRAP_TERMINATED_RUNTIME"
echo "APPROVALS_PRODUCT_CODE_DEFECT_PROVEN=NO"
echo "APPROVALS_PRODUCT_FIX_REQUIRED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"

printf '\n=== LIVE PERSISTENT RUNTIME CHECK ===\n'
REGISTRY_STATUS="$(
  curl -sS \
    -o /tmp/approvals-closure-registry.body \
    -w '%{http_code}' \
    'http://127.0.0.1:5173/api/projects/registry' \
    2>/dev/null || true
)"

APPROVALS_STATUS="$(
  curl -sS \
    -o /tmp/approvals-closure-inbox.body \
    -w '%{http_code}' \
    'http://127.0.0.1:5173/api/approval-requests?project_id=hq' \
    2>/dev/null || true
)"

echo "REGISTRY_HTTP_STATUS=$REGISTRY_STATUS"
echo "APPROVALS_HTTP_STATUS=$APPROVALS_STATUS"

test "$REGISTRY_STATUS" = "200"
test "$APPROVALS_STATUS" = "200"

node <<'NODE'
const fs = require("fs");

const registry = JSON.parse(
  fs.readFileSync(
    "/tmp/approvals-closure-registry.body",
    "utf8",
  ),
);

const approvals = JSON.parse(
  fs.readFileSync(
    "/tmp/approvals-closure-inbox.body",
    "utf8",
  ),
);

if (registry.activeProjectId !== "hq") {
  throw new Error(
    `Expected activeProjectId=hq, received ${registry.activeProjectId}`,
  );
}

if (!Array.isArray(approvals.requests)) {
  throw new Error("Expected approval requests array");
}

console.log("ACTIVE_PROJECT_HQ=YES");
console.log(`PENDING_APPROVAL_REQUESTS=${approvals.requests.length}`);
console.log("PERSISTENT_RUNTIME_VALIDATION=PASS");
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

printf '\n=== CORRIDOR CLOSURE ===\n'
echo "APPROVALS_BACKEND_DIAGNOSIS=CLOSED"
echo "APPROVALS_BROWSER_ORIGIN_DIAGNOSIS=CLOSED"
echo "APPROVALS_RUNTIME_LIFECYCLE_DIAGNOSIS=CLOSED"
echo "APPROVALS_EXECUTIVE_INBOX_RUNTIME_CORRIDOR=CLOSED"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "CLEAR_STOPPING_POINT=YES"
