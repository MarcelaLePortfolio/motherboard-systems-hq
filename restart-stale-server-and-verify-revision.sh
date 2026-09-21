#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="44196b68b"
PORT="3000"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== CONCLUSION ===\n'
echo "FAILURE_CLASS=STALE_RUNNING_SERVER"
echo "PRODUCT_CODE_REPAIR_REQUIRED=NO"
echo "CURRENT_SERVER_RESTART_REQUIRED=YES"
echo "APPROVAL_RETRY_BEFORE_VERIFICATION=NO"

printf '\n=== CAPTURE CURRENT PORT OWNER ===\n'
OLD_PID="$(lsof -tiTCP:${PORT} -sTCP:LISTEN || true)"

test -n "$OLD_PID" || {
  echo "No process is listening on port ${PORT}"
  exit 1
}

echo "OLD_SERVER_PID=$OLD_PID"
ps -p "$OLD_PID" -o pid=,lstart=,command=

printf '\n=== VERIFY SERVER BUILD ===\n'
npm run build

printf '\n=== STOP ONLY STALE PORT-3000 SERVER ===\n'
kill "$OLD_PID"

for _ in $(seq 1 20); do
  if ! kill -0 "$OLD_PID" 2>/dev/null; then
    break
  fi
  sleep 0.25
done

if kill -0 "$OLD_PID" 2>/dev/null; then
  echo "Stale server did not stop cleanly"
  exit 1
fi

printf '\n=== START CURRENT BUILT SERVER ===\n'
nohup node dist/server/index.js \
  > /tmp/motherboard-current-server.log \
  2>&1 &

NEW_PID=$!
echo "NEW_SERVER_PID=$NEW_PID"

for _ in $(seq 1 40); do
  if lsof -tiTCP:${PORT} -sTCP:LISTEN >/dev/null 2>&1; then
    break
  fi
  sleep 0.25
done

LISTENER_PID="$(lsof -tiTCP:${PORT} -sTCP:LISTEN || true)"

test -n "$LISTENER_PID" || {
  echo "Current server failed to bind port ${PORT}"
  cat /tmp/motherboard-current-server.log || true
  exit 1
}

test "$LISTENER_PID" = "$NEW_PID" || {
  echo "Unexpected process owns port ${PORT}: $LISTENER_PID"
  exit 1
}

printf '\n=== CURRENT SERVER PROCESS ===\n'
ps -p "$NEW_PID" -o pid=,lstart=,command=

printf '\n=== VERIFY LIVE APPROVAL REQUEST ===\n'
curl -fsS \
  'http://localhost:3000/api/approval-requests?project_id=hq' \
  > /tmp/current-approval-request.json

cat /tmp/current-approval-request.json
printf '\n'

node <<'NODE'
const fs = require("fs");

const body = JSON.parse(
  fs.readFileSync("/tmp/current-approval-request.json", "utf8"),
);

const requests = Array.isArray(body.requests)
  ? body.requests
  : [];

if (requests.length !== 1) {
  throw new Error(
    `Expected exactly one live Approval Request; received ${requests.length}`,
  );
}

const request = requests[0];

if (
  typeof request.draft_revision_id !== "string" ||
  !request.draft_revision_id.trim()
) {
  throw new Error(
    "Current live Approval Request still lacks draft_revision_id",
  );
}

console.log(
  `LIVE_DRAFT_REVISION_ID=${request.draft_revision_id}`,
);
console.log("LIVE_DRAFT_REVISION_ID_PRESENT=YES");
NODE

printf '\n=== VERIFY REVISION PERSISTED ===\n'
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

try {
  const rows = db.prepare(`
    SELECT
      draft_revision_id,
      draft_package_id,
      lineage_id,
      project_id,
      status,
      created_at
    FROM matilda_draft_revisions
    ORDER BY rowid DESC
  `).all();

  console.log(`DRAFT_REVISION_COUNT=${rows.length}`);

  for (const row of rows) {
    console.log(JSON.stringify(row));
  }

  if (rows.length < 1) {
    throw new Error(
      "No Draft Revision was persisted by current Approval Request assembly",
    );
  }
} finally {
  db.close();
}
NODE

printf '\n=== RUNTIME ALIGNMENT RESULT ===\n'
echo "STALE_SERVER_REPLACED=YES"
echo "CURRENT_SERVER_RUNNING=YES"
echo "LIVE_APPROVAL_REQUEST_HAS_DRAFT_REVISION_ID=YES"
echo "DRAFT_REVISION_PERSISTED=YES"
echo "PRODUCT_CODE_CHANGED=NO"
echo "APPROVAL_RETRIED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=REFRESH_BROWSER_THEN_HUMAN_RUNTIME_APPROVAL_RETRY"
echo "CLEAR_STOPPING_POINT=YES"
