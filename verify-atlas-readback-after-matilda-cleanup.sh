#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="d1cd98ce2"
DB="db/main.db"
PROJECT_ID="hq"
CONVERSATION_ID="matilda-conversation-hq-1789754980083-t80g6h"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$DB"
test -z "$(git diff --cached --name-only)"

printf '\n=== POST-CLEANUP READBACK BOUNDARY ===\n'
echo "MODE=READ_ONLY"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "ATLAS_QA_EVIDENCE_DELETION_AUTHORIZED=NO"
echo "PRODUCT_CODE_MUTATION_AUTHORIZED=NO"
echo "EXPECTED_ATLAS_ROWS=2"
echo "EXPECTED_MATILDA_DOGFOOD_ROWS=0"

printf '\n=== VERIFY MATILDA DOGFOOD REMAINS REMOVED ===\n'
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

  console.log(`POST_CLEANUP_MATILDA_DOGFOOD_TOTAL=${total}`);

  if (total !== 0) {
    throw new Error(
      `Expected zero remaining Matilda dogfood rows, found ${total}.`,
    );
  }

  console.log("MATILDA_DOGFOOD_REMOVAL=PASS");
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY PERSISTED ATLAS QA ROWS ===\n'
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
      project_id,
      conversation_id,
      lineage_id,
      authority_status,
      observed_at,
      persisted_at
    FROM atlas_historical_observations
    WHERE project_id = 'hq'
      AND conversation_id = ?
    ORDER BY observation_id
  `).all(conversationId);

  console.log(`ATLAS_PERSISTED_QA_COUNT=${rows.length}`);

  if (rows.length !== 2) {
    throw new Error(
      `Expected exactly 2 Atlas QA rows, found ${rows.length}.`,
    );
  }

  for (const row of rows) {
    console.log(
      `ATLAS_QA_OBSERVATION=${JSON.stringify(row)}`,
    );
  }

  console.log("ATLAS_PERSISTED_QA_PRESERVATION=PASS");
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY ATLAS PERSISTENCE API READBACK ===\n'
node --import tsx <<'NODE'
import {
  readAtlasHistoricalObservations,
} from "./db/atlas-historical-observation-persistence.ts";

const observations = readAtlasHistoricalObservations("hq");

const scoped = observations.filter(
  (observation) =>
    observation.conversationId ===
    "matilda-conversation-hq-1789754980083-t80g6h",
);

console.log(
  `ATLAS_PERSISTENCE_API_SCOPED_COUNT=${scoped.length}`,
);

console.log(
  "ATLAS_PERSISTENCE_API_SCOPED=" +
    JSON.stringify(scoped, null, 2),
);

if (scoped.length !== 2) {
  throw new Error(
    `Expected persistence API to return 2 scoped observations, found ${scoped.length}.`,
  );
}

console.log("ATLAS_PERSISTENCE_API_READBACK=PASS");
NODE

printf '\n=== VERIFY HTTP ATLAS READBACK WHEN RUNTIME AVAILABLE ===\n'
URL="http://127.0.0.1:5173/atlas/preexecution?projectId=${PROJECT_ID}&conversationId=${CONVERSATION_ID}"

TMP_BODY="$(mktemp)"
trap 'rm -f "$TMP_BODY"' EXIT

HTTP_STATUS="$(curl -sS -o "$TMP_BODY" -w '%{http_code}' "$URL" || true)"

echo "ATLAS_BROWSER_HTTP_STATUS=$HTTP_STATUS"

if [ "$HTTP_STATUS" = "200" ]; then
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

if (observations.length < 2) {
  throw new Error(
    `Expected at least 2 Atlas observations after source-row cleanup, found ${observations.length}.`,
  );
}

const historicalKinds = new Set(
  observations.map((observation) => observation.sourceKind),
);

if (
  !historicalKinds.has("interpretation_evidence") ||
  !historicalKinds.has("living_draft")
) {
  throw new Error(
    "Expected historical interpretation_evidence and living_draft observations are not both present.",
  );
}

console.log("ATLAS_BROWSER_POST_CLEANUP_READBACK=PASS");
NODE
else
  echo "ATLAS_BROWSER_POST_CLEANUP_READBACK=RUNTIME_UNAVAILABLE_OR_NOT_READY"
fi

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
echo "ATLAS_PERSISTENCE_API_READBACK=PASS"
echo "DATABASE_MUTATED_BY_THIS_VERIFICATION=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=IF_BROWSER_READBACK_PASSES_CLOSE_DOGFOOD_CLEANUP_CORRIDOR"
echo "CLEAR_STOPPING_POINT=YES"
