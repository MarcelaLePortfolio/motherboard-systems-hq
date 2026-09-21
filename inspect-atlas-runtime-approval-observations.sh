#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="002d495bf"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== INVESTIGATION BOUNDARY ===\n'
echo "MODE=READ_ONLY"
echo "QUESTION=DID_ATLAS_CAPTURE_THE_CURRENT_MATILDA_APPROVAL_ATTEMPT"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "APPROVAL_RETRY=NO"

printf '\n=== DISCOVER ATLAS OBSERVATION SCHEMA ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", { readonly: true });

try {
  const tables = db.prepare(`
    SELECT name, sql
    FROM sqlite_master
    WHERE type = 'table'
      AND lower(name) LIKE '%atlas%'
    ORDER BY name
  `).all();

  console.log(`ATLAS_TABLE_COUNT=${tables.length}`);

  for (const table of tables) {
    console.log(`\nATLAS_TABLE=${table.name}`);
    console.log(table.sql || "SCHEMA_UNAVAILABLE");
  }
} finally {
  db.close();
}
NODE

printf '\n=== READ CURRENT ATLAS OBSERVATIONS ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", { readonly: true });

try {
  const tables = db.prepare(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND lower(name) LIKE '%atlas%'
    ORDER BY name
  `).pluck().all();

  for (const table of tables) {
    const quoted = `"${String(table).replace(/"/g, '""')}"`;
    const columns = db.prepare(`PRAGMA table_info(${quoted})`).all();
    const names = new Set(columns.map((column) => column.name));

    console.log(`\n=== ${table} ===`);

    const orderBy =
      names.has("observation_id")
        ? "observation_id DESC"
        : names.has("created_at")
          ? "created_at DESC"
          : "rowid DESC";

    const rows = db.prepare(`
      SELECT *
      FROM ${quoted}
      ORDER BY ${orderBy}
      LIMIT 25
    `).all();

    console.log(`ROW_COUNT_SHOWN=${rows.length}`);

    for (const row of rows) {
      console.log(JSON.stringify(row));
    }
  }
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY READ ONLY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== STOPPING POINT ===\n'
echo "ATLAS_OBSERVATION_INSPECTION_COMPLETE=YES"
echo "ATLAS_CAPTURE_STATUS=DETERMINE_FROM_OUTPUT"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "APPROVAL_RETRIED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=CLASSIFY_ATLAS_CAPTURE_AND_THEN_INSPECT_LIVE_APPROVAL_REQUEST"
echo "CLEAR_STOPPING_POINT=YES"
