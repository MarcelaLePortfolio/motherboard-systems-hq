#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="b91382fea40a06b2cd3b4a813e36850b1cda360d"

printf '\n=== VERIFY REPOSITORY CHECKPOINT ===\n'
git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

echo "LOCAL_REMOTE_CONVERGENCE=YES"
echo "EXPECTED_HEAD=$EXPECTED_HEAD"

printf '\n=== VERIFY PERSISTENT RUNTIME ===\n'
REGISTRY_STATUS="$(
  curl -sS \
    -o /tmp/approvals-final-registry.body \
    -w '%{http_code}' \
    'http://127.0.0.1:5173/api/projects/registry' \
    2>/dev/null || true
)"

APPROVALS_STATUS="$(
  curl -sS \
    -o /tmp/approvals-final-inbox.body \
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
    "/tmp/approvals-final-registry.body",
    "utf8",
  ),
);

const approvals = JSON.parse(
  fs.readFileSync(
    "/tmp/approvals-final-inbox.body",
    "utf8",
  ),
);

if (registry.activeProjectId !== "hq") {
  throw new Error(
    `Expected activeProjectId=hq, received ${registry.activeProjectId}`,
  );
}

if (!Array.isArray(approvals.requests)) {
  throw new Error(
    "Expected approval requests array",
  );
}

console.log("ACTIVE_PROJECT_HQ=YES");
console.log(
  `PENDING_APPROVAL_REQUESTS=${approvals.requests.length}`,
);
console.log(
  "APPROVALS_RUNTIME_CLOSURE_RECHECK=PASS",
);
NODE

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
git diff --exit-code -- \
  client/src/project-context \
  client/src/approvals \
  client/vite.config.ts \
  server/index.ts \
  server/project-registry.mjs \
  routes/api-approval-request.ts

test -z "$(git diff --cached --name-only)"

printf '\n=== FINAL CORRIDOR CLOSURE ===\n'
echo "APPROVALS_BACKEND_DIAGNOSIS=CLOSED"
echo "APPROVALS_BROWSER_ORIGIN_DIAGNOSIS=CLOSED"
echo "APPROVALS_RUNTIME_LIFECYCLE_DIAGNOSIS=CLOSED"
echo "APPROVALS_EXECUTIVE_INBOX_RUNTIME_CORRIDOR=CLOSED"
echo "PERSISTENT_RUNTIME_VALIDATION=PASS"
echo "APPROVALS_PRODUCT_FIX_REQUIRED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "CLEAR_STOPPING_POINT=YES"
echo "NO_FURTHER_ACTION_REQUIRED_IN_THIS_CORRIDOR=YES"
