#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== BROWSER VALIDATION CLASSIFICATION ===\n'
echo "EXECUTIVE_INBOX_BROWSER_VALIDATION=BLOCKED"
echo "BLOCKER=PROJECT_REGISTRY_OR_ACTIVE_PROJECT_UNAVAILABLE"
echo "APPROVALS_BACKEND=HEALTHY"
echo "ATLAS_BACKEND_PATH=PREVIOUSLY_PROVEN"
echo "APPROVALS_PRODUCT_DEFECT_PROVEN=NO"
echo "ATLAS_PRODUCT_DEFECT_PROVEN=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== INSPECT PROJECT REGISTRY CLIENT CONTRACT ===\n'
sed -n '1,240p' client/src/project-context/projectRegistryApi.ts

printf '\n=== INSPECT PROJECT CONTEXT UI / PROVIDER ===\n'
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E 'Project Registry unavailable|No active project is available|ACTIVE_PROJECT_ENDPOINT|PROJECT_REGISTRY_ENDPOINT|activeProject|project registry' \
  client/src \
  | head -n 420 || true

printf '\n=== INSPECT SERVER PROJECT ROUTES ===\n'
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E 'project-registry|active-project|project-context|project registry' \
  server routes db \
  | head -n 520 || true

printf '\n=== INSPECT SERVER MOUNTS ===\n'
grep -n -A25 -B10 \
  -E 'project|registry|context' \
  server/index.ts \
  | head -n 260 || true

printf '\n=== START EXISTING RUNTIME TEMPORARILY ===\n'
SERVER_LOG="/tmp/motherboard-project-registry-runtime.log"
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
  echo "NEXT_ACTION=DIAGNOSE_SERVER_START_ONLY"
  exit 1
fi

printf '\n=== PROBE PROJECT REGISTRY ENDPOINT CANDIDATES ===\n'
node <<'NODE'
const fs = require("fs");

const text = fs.readFileSync(
  "client/src/project-context/projectRegistryApi.ts",
  "utf8",
);

const matches = [
  ...text.matchAll(/const\s+([A-Z0-9_]+)\s*=\s*["'`]([^"'`]+)["'`]/g),
];

for (const match of matches) {
  const [, name, value] = match;

  if (
    /PROJECT|REGISTRY|ACTIVE/i.test(name) &&
    value.startsWith("/")
  ) {
    console.log(`${name}=${value}`);
  }
}
NODE

mapfile -t ENDPOINTS < <(
  node <<'NODE'
const fs = require("fs");

const text = fs.readFileSync(
  "client/src/project-context/projectRegistryApi.ts",
  "utf8",
);

const values = new Set();

for (
  const match of text.matchAll(
    /const\s+([A-Z0-9_]+)\s*=\s*["'`]([^"'`]+)["'`]/g,
  )
) {
  const [, name, value] = match;

  if (
    /PROJECT|REGISTRY|ACTIVE/i.test(name) &&
    value.startsWith("/")
  ) {
    values.add(value);
  }
}

for (const value of values) {
  console.log(value);
}
NODE
)

if [ "${#ENDPOINTS[@]}" -eq 0 ]; then
  echo "PROJECT_ENDPOINT_DISCOVERY=NONE"
else
  for endpoint in "${ENDPOINTS[@]}"; do
    printf '\n--- GET %s ---\n' "$endpoint"

    STATUS="$(
      curl -sS \
        -o /tmp/project-endpoint.body \
        -w '%{http_code}' \
        "http://127.0.0.1:3000${endpoint}" \
        || true
    )"

    echo "HTTP_STATUS=$STATUS"

    if [ -f /tmp/project-endpoint.body ]; then
      head -c 4000 /tmp/project-endpoint.body
      printf '\n'
    fi
  done
fi

printf '\n=== VERIFY HQ PROJECT REGISTRY DATABASE STATE ===\n'
node --import tsx <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

try {
  const tables = db.prepare(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND name LIKE '%project%'
    ORDER BY name
  `).all();

  console.log(
    "PROJECT_RELATED_TABLES=" +
      JSON.stringify(tables),
  );

  if (
    tables.some(
      (row) => row.name === "project_registry",
    )
  ) {
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
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/project-context/projectRegistryApi.ts \
  server/index.ts \
  server/project-registry.mjs

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "APPROVALS_BROWSER_VALIDATION=BLOCKED_BY_PROJECT_CONTEXT"
echo "PROJECT_REGISTRY_DIAGNOSIS=IN_PROGRESS"
echo "APPROVALS_FIX_EXECUTED=NO"
echo "ATLAS_FIX_EXECUTED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "CLEAR_STOPPING_POINT=YES"
echo "NEXT_ACTION=CLASSIFY_EXACT_PROJECT_REGISTRY_OR_ACTIVE_PROJECT_FAILURE"
