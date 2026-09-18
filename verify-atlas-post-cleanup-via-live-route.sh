#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="3442da84e"
DB="db/main.db"
PROJECT_ID="hq"
CONVERSATION_ID="matilda-conversation-hq-1789754980083-t80g6h"
URL="http://127.0.0.1:5173/atlas/preexecution?projectId=${PROJECT_ID}&conversationId=${CONVERSATION_ID}"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$DB"
test -z "$(git diff --cached --name-only)"

printf '\n=== FAILURE CLASSIFICATION ===\n'
echo "PREVIOUS_FAILURE=NODE_NAMED_IMPORT_MISMATCH"
echo "MATILDA_CLEANUP_FAILURE=NO"
echo "ATLAS_PERSISTENCE_FAILURE=NO"
echo "PRODUCT_HYPOTHESIS_FAILURE=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "PRODUCT_CODE_MUTATION_AUTHORIZED=NO"

printf '\n=== VERIFY MATILDA SOURCE ROWS REMAIN ABSENT ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

const conversationId =
  "matilda-conversation-hq-1789754980083-t80g6h";

try {
  const tables = [
    "matilda_active_conversation_context",
    "matilda_conversation_turns",
    "matilda_conversations",
    "matilda_interpretation_evidence_ledger",
    "matilda_living_draft_packages",
  ];

  let total = 0;

  for (const table of tables) {
    const count = db.prepare(`
      SELECT COUNT(*) AS count
      FROM ${table}
      WHERE conversation_id = ?
    `).get(conversationId).count;

    console.log(`${table.toUpperCase()}=${count}`);
    total += count;
  }

  if (total !== 0) {
    throw new Error(
      `Expected zero Matilda dogfood rows, found ${total}.`,
    );
  }

  console.log("MATILDA_DOGFOOD_REMOVAL=PASS");
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY RAW ATLAS QA PERSISTENCE ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

const conversationId =
  "matilda-conversation-hq-1789754980083-t80g6h";

try {
  const rows = db.prepare(`
    SELECT
      observation_id,
      source_kind,
      source_identity,
      authority_status
    FROM atlas_historical_observations
    WHERE project_id = 'hq'
      AND conversation_id = ?
    ORDER BY observation_id
  `).all(conversationId);

  console.log(`ATLAS_PERSISTED_QA_COUNT=${rows.length}`);

  if (rows.length !== 2) {
    throw new Error(
      `Expected 2 persisted Atlas QA rows, found ${rows.length}.`,
    );
  }

  const kinds = new Set(rows.map((row) => row.source_kind));

  if (
    !kinds.has("interpretation_evidence") ||
    !kinds.has("living_draft")
  ) {
    throw new Error(
      "Expected Atlas interpretation_evidence and living_draft rows.",
    );
  }

  for (const row of rows) {
    console.log(
      `PRESERVED_ATLAS_QA=${JSON.stringify(row)}`,
    );
  }

  console.log("ATLAS_RAW_PERSISTENCE=PASS");
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY LIVE ATLAS READBACK ===\n'
TMP_BODY="$(mktemp)"
trap 'rm -f "$TMP_BODY"' EXIT

HTTP_STATUS="$(curl -sS -o "$TMP_BODY" -w '%{http_code}' "$URL" || true)"

echo "ATLAS_BROWSER_HTTP_STATUS=$HTTP_STATUS"

if [ "$HTTP_STATUS" != "200" ]; then
  echo "ATLAS_LIVE_READBACK=RUNTIME_NOT_AVAILABLE"
  exit 2
fi

node - "$TMP_BODY" <<'NODE'
const fs = require("fs");

const path = process.argv[2];
const raw = fs.readFileSync(path, "utf8");
const parsed = JSON.parse(raw);

const observations = Array.isArray(parsed.observations)
  ? parsed.observations
  : [];

console.log(
  `ATLAS_BROWSER_OBSERVATION_COUNT=${observations.length}`,
);

console.log(
  "ATLAS_BROWSER_OBSERVATIONS=" +
    JSON.stringify(observations, null, 2),
);

const kinds = new Set(
  observations.map((observation) => observation.sourceKind),
);

if (
  !kinds.has("interpretation_evidence") ||
  !kinds.has("living_draft")
) {
  throw new Error(
    "Live Atlas route did not return both preserved historical QA observation kinds.",
  );
}

console.log("ATLAS_LIVE_POST_CLEANUP_READBACK=PASS");
NODE

printf '\n=== DATABASE INTEGRITY ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

try {
  const integrity =
    db.prepare("PRAGMA integrity_check").pluck().get();

  console.log(`DATABASE_INTEGRITY=${integrity}`);

  if (integrity !== "ok") {
    throw new Error(
      `Database integrity check failed: ${integrity}`,
    );
  }
} finally {
  db.close();
}
NODE

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "MATILDA_COLLABORATION_DOGFOOD_REMOVED=YES"
echo "ATLAS_QA_ROWS_PRESERVED=2"
echo "ATLAS_LIVE_POST_CLEANUP_READBACK=PASS"
echo "DATABASE_INTEGRITY=ok"
echo "DATABASE_MUTATED_BY_THIS_VERIFICATION=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=CLOSE_MATILDA_DOGFOOD_CLEANUP_CORRIDOR"
echo "CLEAR_STOPPING_POINT=YES"
