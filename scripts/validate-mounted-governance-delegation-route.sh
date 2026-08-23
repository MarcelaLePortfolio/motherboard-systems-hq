#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

PORT="${PORT:-3317}"
BASE_URL="http://127.0.0.1:${PORT}"
LOG_FILE="/tmp/motherboard-delegation-route-${PORT}.log"

CANONICAL_PACKAGE_JSON="$(
  node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });
const row = db.prepare(`
  SELECT package_id, package_version
  FROM matilda_canonical_packages
  WHERE status = 'canonical_approved'
  ORDER BY package_version DESC
  LIMIT 1
`).get();
db.close();

if (!row) process.exit(2);
process.stdout.write(JSON.stringify(row));
NODE
)"

PACKAGE_ID="$(node -e 'const x=JSON.parse(process.argv[1]); process.stdout.write(x.package_id)' "$CANONICAL_PACKAGE_JSON")"
PACKAGE_VERSION="$(node -e 'const x=JSON.parse(process.argv[1]); process.stdout.write(String(x.package_version))' "$CANONICAL_PACKAGE_JSON")"
DELEGATION_ID="mounted-route-validation-$(date +%s)"
LEGACY_DELEGATION_ID="mounted-legacy-rejection-$(date +%s)"

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]]; then
    kill "${SERVER_PID}" >/dev/null 2>&1 || true
    wait "${SERVER_PID}" >/dev/null 2>&1 || true
  fi

  node <<NODE
const Database = require("better-sqlite3");
const db = new Database("db/main.db");
db.prepare("DELETE FROM governance_delegations WHERE delegation_id IN (?, ?)")
  .run("${DELEGATION_ID}", "${LEGACY_DELEGATION_ID}");
db.close();
NODE
}
trap cleanup EXIT

printf '\n=== DISCOVER NATIVE SERVER COMMAND ===\n'
node <<'NODE'
const pkg = require("./package.json");
console.log(pkg.scripts || {});
NODE

printf '\n=== START SERVER WITH NATIVE TSX EXECUTION ===\n'
PORT="${PORT}" npx tsx server/index.ts >"${LOG_FILE}" 2>&1 &
SERVER_PID=$!

for _ in $(seq 1 40); do
  if curl -sS "${BASE_URL}/ui" >/dev/null 2>&1; then
    break
  fi

  if ! kill -0 "${SERVER_PID}" >/dev/null 2>&1; then
    cat "${LOG_FILE}"
    exit 1
  fi

  sleep 0.25
done

if ! curl -sS "${BASE_URL}/ui" >/dev/null 2>&1; then
  cat "${LOG_FILE}"
  echo "SERVER_STARTUP=FAIL"
  exit 1
fi

echo "SERVER_STARTUP=PASS"

printf '\n=== POST EXPLICIT CANONICAL DELEGATION ===\n'
HTTP_BODY="$(
  curl -sS \
    -X POST \
    -H 'Content-Type: application/json' \
    -d "{
      \"delegation_id\":\"${DELEGATION_ID}\",
      \"package_id\":\"${PACKAGE_ID}\",
      \"package_version\":${PACKAGE_VERSION},
      \"authorization_state\":\"AUTHORIZED\",
      \"delegated_by\":\"marcela\"
    }" \
    "${BASE_URL}/api/governance/delegation"
)"

printf '%s\n' "${HTTP_BODY}"

HTTP_BODY="${HTTP_BODY}" PACKAGE_ID="${PACKAGE_ID}" PACKAGE_VERSION="${PACKAGE_VERSION}" node <<'NODE'
const response = JSON.parse(process.env.HTTP_BODY);
const packageVersion = Number(process.env.PACKAGE_VERSION);

if (response.ok !== true) {
  throw new Error("Mounted Delegation route did not succeed.");
}

if (response.route !== "governance_delegation_route") {
  throw new Error("Unexpected route identity.");
}

if (
  response.delegation?.delegation?.package_id !== process.env.PACKAGE_ID ||
  response.delegation?.delegation?.package_version !== packageVersion
) {
  throw new Error("Mounted route did not preserve exact Canonical Package identity.");
}

for (const flag of [
  "scheduler_authorized",
  "worker_claim_authorized",
  "orchestration_authorized",
  "routing_authorized",
  "assignment_authorized",
  "lifecycle_transition_authorized",
  "execution_authorized",
  "downstream_governance_authorized",
  "new_authority_introduced",
]) {
  if (response[flag] !== false) {
    throw new Error(`${flag} must remain false.`);
  }
}

console.log("MOUNTED_DELEGATION_ROUTE=PASS");
console.log("EXACT_CANONICAL_PACKAGE_IDENTITY=PASS");
console.log("DOWNSTREAM_AUTHORITY_REMAINS_OFF=PASS");
NODE

printf '\n=== PERSISTED DELEGATION ===\n'
DELEGATION_ID="${DELEGATION_ID}" PACKAGE_ID="${PACKAGE_ID}" PACKAGE_VERSION="${PACKAGE_VERSION}" node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

const row = db.prepare(`
  SELECT delegation_id, package_id, package_version, authorization_state, delegated_by
  FROM governance_delegations
  WHERE delegation_id = ?
`).get(process.env.DELEGATION_ID);

console.log(row);

if (!row) throw new Error("Mounted Delegation request did not persist.");

if (
  row.package_id !== process.env.PACKAGE_ID ||
  row.package_version !== Number(process.env.PACKAGE_VERSION)
) {
  throw new Error("Persisted Delegation lost Canonical Package identity.");
}

console.log("HTTP_TO_PERSISTENCE=PASS");
db.close();
NODE

printf '\n=== LEGACY NEW-CREATION REJECTION OVER HTTP ===\n'
LEGACY_RESPONSE="$(
  curl -sS \
    -X POST \
    -H 'Content-Type: application/json' \
    -d "{
      \"delegation_id\":\"${LEGACY_DELEGATION_ID}\",
      \"package_id\":\"corridor-smoke\",
      \"package_version\":1,
      \"authorization_state\":\"AUTHORIZED\",
      \"delegated_by\":\"marcela\"
    }" \
    "${BASE_URL}/api/governance/delegation"
)"

printf '%s\n' "${LEGACY_RESPONSE}"

LEGACY_RESPONSE="${LEGACY_RESPONSE}" node <<'NODE'
const response = JSON.parse(process.env.LEGACY_RESPONSE);

if (response.ok !== false) {
  throw new Error("Legacy governance Package unexpectedly created a new Delegation.");
}

if (!/existing Canonical Package version/i.test(JSON.stringify(response))) {
  throw new Error("Legacy rejection did not fail for the Canonical Package root requirement.");
}

console.log("LEGACY_HTTP_NEW_DELEGATION_REJECTED=PASS");
NODE

printf '\n=== SERVER LOG ===\n'
cat "${LOG_FILE}"

printf '\n=== WORKTREE ===\n'
git status --short
