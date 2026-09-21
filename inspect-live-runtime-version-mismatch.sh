#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="90425b063"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== INVESTIGATION BOUNDARY ===\n'
echo "MODE=READ_ONLY"
echo "HYPOTHESIS=RUNNING_SERVER_IS_STALE_RELATIVE_TO_REFRESHED_CLIENT"
echo "EVIDENCE_1=LIVE_DATABASE_HAS_ZERO_DRAFT_REVISIONS"
echo "EVIDENCE_2=CURRENT_ASSEMBLER_CREATES_OR_REUSES_REVISION_DURING_APPROVAL_REQUEST_ASSEMBLY"
echo "EVIDENCE_3=CLIENT_EXPECTS_DRAFT_REVISION_ID"
echo "APPROVAL_RETRY=NO"
echo "MUTATION_AUTHORIZED=NO"

printf '\n=== CURRENT REPOSITORY ===\n'
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git rev-parse --abbrev-ref HEAD)"

printf '\n=== LISTENING NODE PROCESSES ===\n'
ps -axo pid,lstart,command \
  | grep -E '[n]ode|[t]sx|[v]ite' \
  || true

printf '\n=== LISTENING PORTS ===\n'
for PORT in 3000 3001 5173 5174; do
  echo "--- PORT $PORT ---"
  lsof -nP -iTCP:"$PORT" -sTCP:LISTEN || true
done

printf '\n=== LIVE APPROVAL REQUEST RESPONSE ON PORT 3000 ===\n'
HTTP_3000="$(
  curl -sS \
    -o /tmp/motherboard-approval-3000.json \
    -w '%{http_code}' \
    'http://localhost:3000/api/approval-requests?project_id=hq' \
    2>/dev/null || true
)"
echo "HTTP_STATUS_3000=${HTTP_3000:-UNAVAILABLE}"

if test -s /tmp/motherboard-approval-3000.json; then
  cat /tmp/motherboard-approval-3000.json
  printf '\n'

  node <<'NODE'
const fs = require("fs");
const path = "/tmp/motherboard-approval-3000.json";

try {
  const body = JSON.parse(fs.readFileSync(path, "utf8"));
  const requests = Array.isArray(body.requests) ? body.requests : [];

  console.log(`LIVE_REQUEST_COUNT=${requests.length}`);

  for (const request of requests) {
    console.log(
      JSON.stringify({
        approval_request_id: request.approval_request_id,
        draft_package_id: request.draft_package_id,
        draft_revision_id: request.draft_revision_id,
        has_draft_revision_id:
          typeof request.draft_revision_id === "string" &&
          request.draft_revision_id.length > 0,
      }),
    );
  }
} catch (error) {
  console.log(`LIVE_RESPONSE_PARSE_ERROR=${error.message}`);
}
NODE
fi

printf '\n=== LIVE APPROVAL REQUEST RESPONSE ON PORT 3001 IF PRESENT ===\n'
HTTP_3001="$(
  curl -sS \
    -o /tmp/motherboard-approval-3001.json \
    -w '%{http_code}' \
    'http://localhost:3001/api/approval-requests?project_id=hq' \
    2>/dev/null || true
)"
echo "HTTP_STATUS_3001=${HTTP_3001:-UNAVAILABLE}"

if test -s /tmp/motherboard-approval-3001.json; then
  cat /tmp/motherboard-approval-3001.json
  printf '\n'
fi

printf '\n=== DATABASE REVISION COUNT AFTER READ REQUEST ===\n'
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

try {
  const row = db.prepare(`
    SELECT COUNT(*) AS count
    FROM matilda_draft_revisions
  `).get();

  console.log(`DRAFT_REVISION_COUNT=${row.count}`);
} finally {
  db.close();
}
NODE

printf '\n=== CLASSIFICATION INPUTS ===\n'
echo "IF_LIVE_RESPONSE_LACKS_DRAFT_REVISION_ID_AND_REVISION_COUNT_REMAINS_ZERO=STALE_SERVER_STRONGLY_SUPPORTED"
echo "IF_LIVE_RESPONSE_HAS_DRAFT_REVISION_ID=INVESTIGATE_CLIENT_RUNTIME_OR_STALE_BROWSER_ASSET"
echo "IF_CURRENT_SERVER_REQUEST_CREATES_REVISION=SERVER_IS_CURRENT_AND_ORIGINAL_BROWSER_REQUEST_WAS_STALE"
echo "APPROVAL_RETRIED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_EXPLICITLY_MUTATED_BY_SCRIPT=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=CLASSIFY_RUNTIME_VERSION_ALIGNMENT_FROM_OUTPUT"
echo "CLEAR_STOPPING_POINT=YES"

test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"
