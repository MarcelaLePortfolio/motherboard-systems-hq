#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== PRESERVE CURRENT DIAGNOSIS ===\n'
echo "EXECUTIVE_INBOX_BROWSER_VALIDATION=BLOCKED"
echo "VISIBLE_BROWSER_BLOCKER=PROJECT_REGISTRY_OR_ACTIVE_PROJECT_UNAVAILABLE"
echo "APPROVALS_BACKEND=HEALTHY_WHEN_RUNTIME_RUNNING"
echo "ATLAS_CORRIDOR=CLOSED"
echo "PREVIOUS_DIAGNOSTIC_SCRIPT=TOOLING_FAILURE"
echo "PREVIOUS_FAILURE=UNMATCHED_SHELL_QUOTE"
echo "PRODUCT_HYPOTHESIS_FAILURE=NO"
echo "FAILED_HYPOTHESIS_COUNT_UNCHANGED=YES"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== VERIFIED ROUTE CONTRACT ===\n'
grep -n -E \
  'PROJECT_REGISTRY_ENDPOINT|ACTIVE_PROJECT_ENDPOINT' \
  client/src/project-context/projectRegistryApi.ts

grep -n -A18 -B8 \
  'mountProjectRegistryRoutes' \
  server/index.ts

printf '\n=== START EXISTING RUNTIME ===\n'
SERVER_LOG="/tmp/motherboard-project-registry-runtime-v2.log"
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
    "http://127.0.0.1:3000/" \
    2>/dev/null; then
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
  echo "PROJECT_REGISTRY_DIAGNOSIS=BLOCKED_BY_SERVER_START"
  echo "NEXT_ACTION=DIAGNOSE_SERVER_START_ONLY"
  exit 1
fi

printf '\n=== PROBE PROJECT REGISTRY ===\n'
REGISTRY_STATUS="$(
  curl -sS \
    -o /tmp/project-registry-v2.body \
    -w '%{http_code}' \
    'http://127.0.0.1:3000/api/projects/registry' \
    || true
)"

echo "PROJECT_REGISTRY_HTTP_STATUS=$REGISTRY_STATUS"
echo "PROJECT_REGISTRY_RESPONSE_BEGIN"
cat /tmp/project-registry-v2.body 2>/dev/null || true
printf '\n'
echo "PROJECT_REGISTRY_RESPONSE_END"

printf '\n=== PROBE APPROVALS CONTROL ENDPOINT ===\n'
APPROVALS_STATUS="$(
  curl -sS \
    -o /tmp/approvals-control-v2.body \
    -w '%{http_code}' \
    'http://127.0.0.1:3000/api/approval-requests?project_id=hq' \
    || true
)"

echo "APPROVALS_HTTP_STATUS=$APPROVALS_STATUS"

printf '\n=== READ PROJECT REGISTRY DATABASE STATE ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

try {
  const table = db.prepare(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND name = 'project_registry'
  `).get();

  console.log(
    `PROJECT_REGISTRY_TABLE_PRESENT=${table ? "YES" : "NO"}`,
  );

  if (table) {
    const rows = db.prepare(`
      SELECT *
      FROM project_registry
      ORDER BY project_id
    `).all();

    console.log(
      "PROJECT_REGISTRY_ROWS=" +
        JSON.stringify(rows),
    );
  }

  const activeTables = db.prepare(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND (
        name LIKE '%active%project%' OR
        name LIKE '%project%context%'
      )
    ORDER BY name
  `).all();

  console.log(
    "ACTIVE_PROJECT_RELATED_TABLES=" +
      JSON.stringify(activeTables),
  );
} finally {
  db.close();
}
NODE

printf '\n=== CLASSIFY EXACT FAILURE LAYER ===\n'

if [ "$REGISTRY_STATUS" = "200" ]; then
  node <<'NODE'
const fs = require("fs");

const payload = JSON.parse(
  fs.readFileSync(
    "/tmp/project-registry-v2.body",
    "utf8",
  ),
);

console.log(
  "PROJECT_REGISTRY_PAYLOAD=" +
    JSON.stringify(payload),
);

const projects =
  Array.isArray(payload.projects)
    ? payload.projects
    : [];

const activeProjectId =
  payload.activeProjectId ??
  payload.active_project_id ??
  payload.activeProject?.projectId ??
  payload.activeProject?.project_id ??
  null;

console.log(
  `REGISTRY_PROJECT_COUNT=${projects.length}`,
);
console.log(
  `REGISTRY_ACTIVE_PROJECT_ID=${activeProjectId ?? "NONE"}`,
);

if (projects.length === 0) {
  console.log(
    "EXACT_FAILURE_CLASS=SERVER_REGISTRY_RESPONSE_HAS_NO_PROJECTS",
  );
} else if (!activeProjectId) {
  console.log(
    "EXACT_FAILURE_CLASS=SERVER_REGISTRY_HAS_PROJECTS_BUT_NO_ACTIVE_PROJECT",
  );
} else {
  console.log(
    "EXACT_FAILURE_CLASS=SERVER_REGISTRY_HEALTHY_BROWSER_CLIENT_CONTEXT_FAILURE",
  );
}
NODE
else
  echo "EXACT_FAILURE_CLASS=PROJECT_REGISTRY_HTTP_ENDPOINT_FAILURE"
fi

printf '\n=== SERVER LOG TAIL ===\n'
tail -n 120 "$SERVER_LOG" || true

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/project-context/projectRegistryApi.ts \
  client/src/project-context/ProjectContextControl.tsx \
  server/index.ts \
  server/project-registry.mjs

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "PROJECT_REGISTRY_DIAGNOSTIC_RETRY=COMPLETE"
echo "PREVIOUS_QUOTING_FAILURE=CORRECTED"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "CLEAR_STOPPING_POINT=YES"
echo "NEXT_ACTION=USE_EXACT_FAILURE_CLASS_ABOVE_TO_SELECT_ONE_CONFIDENT_NEXT_STEP"
