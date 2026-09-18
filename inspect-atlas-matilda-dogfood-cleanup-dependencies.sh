#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
DOGFOOD_CONVERSATION_ID="matilda-conversation-hq-1789754980083-t80g6h"
PROJECT_ID="hq"
DB="db/main.db"

printf '\n=== INVESTIGATION BOUNDARY ===\n'
echo "MODE=READ_ONLY_DEPENDENCY_MAPPING"
echo "DR_CHECKPOINT=20260918_142139"
echo "PROJECT_ID=$PROJECT_ID"
echo "DOGFOOD_CONVERSATION_ID=$DOGFOOD_CONVERSATION_ID"
echo "DATABASE=$DB"
echo "CLEANUP_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "ATLAS_QA_EVIDENCE_DELETION_AUTHORIZED=NO"

printf '\n=== VERIFY REPOSITORY STATE ===\n'
git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

PRE_HEAD="$(git rev-parse HEAD)"
echo "PRE_HEAD=$PRE_HEAD"
echo "REMOTE_HEAD=$(git rev-parse "origin/$BRANCH")"

test -f "$DB"

printf '\n=== MAP DATABASE TABLES AND FOREIGN KEYS ===\n'
node <<'NODE'
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
      AND (
        name LIKE 'matilda_%'
        OR name LIKE 'atlas_%'
        OR name LIKE '%approval%'
        OR name LIKE 'governance_%'
      )
    ORDER BY name
  `).all();

  console.log(
    "RELEVANT_TABLES=" +
      JSON.stringify(tables.map((row) => row.name)),
  );

  for (const { name } of tables) {
    const escaped = name.replace(/"/g, '""');

    const columns = db
      .prepare(`PRAGMA table_info("${escaped}")`)
      .all();

    const foreignKeys = db
      .prepare(`PRAGMA foreign_key_list("${escaped}")`)
      .all();

    console.log(`\nTABLE=${name}`);
    console.log(
      "COLUMNS=" +
        JSON.stringify(
          columns.map((column) => ({
            name: column.name,
            type: column.type,
            pk: column.pk,
          })),
        ),
    );
    console.log(
      "FOREIGN_KEYS=" + JSON.stringify(foreignKeys),
    );
  }
} finally {
  db.close();
}
NODE

printf '\n=== FIND DOGFOOD REFERENCES ACROSS RELEVANT TABLES ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

const conversationId =
  "matilda-conversation-hq-1789754980083-t80g6h";

try {
  const tables = db.prepare(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND name NOT LIKE 'sqlite_%'
    ORDER BY name
  `).all();

  let totalMatchingRows = 0;
  const matchingTables = [];

  for (const { name } of tables) {
    const escapedTable = name.replace(/"/g, '""');

    const columns = db
      .prepare(`PRAGMA table_info("${escapedTable}")`)
      .all();

    const searchableColumns = columns.filter((column) => {
      const type = String(column.type || "").toUpperCase();

      return (
        type.includes("TEXT") ||
        type.includes("CHAR") ||
        type.includes("CLOB") ||
        type === ""
      );
    });

    if (searchableColumns.length === 0) {
      continue;
    }

    const predicates = searchableColumns.map((column) => {
      const escapedColumn = column.name.replace(/"/g, '""');
      return `CAST("${escapedColumn}" AS TEXT) LIKE ?`;
    });

    const params = searchableColumns.map(
      () => `%${conversationId}%`,
    );

    let rows;

    try {
      rows = db
        .prepare(
          `SELECT * FROM "${escapedTable}"
           WHERE ${predicates.join(" OR ")}`,
        )
        .all(...params);
    } catch (error) {
      console.log(
        `TABLE_SCAN_SKIPPED=${name}:${error.message}`,
      );
      continue;
    }

    if (rows.length === 0) {
      continue;
    }

    totalMatchingRows += rows.length;
    matchingTables.push({
      table: name,
      rowCount: rows.length,
    });

    console.log(`\nDOGFOOD_REFERENCE_TABLE=${name}`);
    console.log(`DOGFOOD_REFERENCE_ROW_COUNT=${rows.length}`);
    console.log(
      "DOGFOOD_REFERENCE_ROWS=" +
        JSON.stringify(rows, null, 2),
    );
  }

  console.log(
    "\nDOGFOOD_MATCHING_TABLES=" +
      JSON.stringify(matchingTables),
  );
  console.log(
    `DOGFOOD_TOTAL_MATCHING_ROWS=${totalMatchingRows}`,
  );
} finally {
  db.close();
}
NODE

printf '\n=== IDENTIFY ATLAS PERSISTED COPIES ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

const conversationId =
  "matilda-conversation-hq-1789754980083-t80g6h";

try {
  const atlasTables = db.prepare(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND name LIKE 'atlas_%'
    ORDER BY name
  `).all();

  console.log(
    "ATLAS_TABLES=" +
      JSON.stringify(atlasTables.map((row) => row.name)),
  );

  for (const { name } of atlasTables) {
    const escapedTable = name.replace(/"/g, '""');

    const columns = db
      .prepare(`PRAGMA table_info("${escapedTable}")`)
      .all();

    const searchable = columns.filter((column) => {
      const type = String(column.type || "").toUpperCase();

      return (
        type.includes("TEXT") ||
        type.includes("CHAR") ||
        type.includes("CLOB") ||
        type === ""
      );
    });

    if (!searchable.length) continue;

    const predicates = searchable.map((column) => {
      const escapedColumn = column.name.replace(/"/g, '""');
      return `CAST("${escapedColumn}" AS TEXT) LIKE ?`;
    });

    const params = searchable.map(
      () => `%${conversationId}%`,
    );

    const rows = db.prepare(
      `SELECT * FROM "${escapedTable}"
       WHERE ${predicates.join(" OR ")}`,
    ).all(...params);

    console.log(`\nATLAS_TABLE=${name}`);
    console.log(`ATLAS_DOGFOOD_ROW_COUNT=${rows.length}`);

    if (rows.length) {
      console.log(
        "ATLAS_DOGFOOD_ROWS=" +
          JSON.stringify(rows, null, 2),
      );
    }
  }
} finally {
  db.close();
}
NODE

printf '\n=== INSPECT ATLAS READBACK IMPLEMENTATION DEPENDENCIES ===\n'
grep -RniE \
  'atlas_historical|historical_observation|matilda_|conversationId|conversation_id|living_draft|interpretation_evidence|pending_approval' \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts \
  2>/dev/null || true

printf '\n=== TEST CURRENT ATLAS READBACK ===\n'
node --import tsx <<'NODE'
import {
  readAtlasHistoricalObservations,
} from "./db/atlas-historical-observation-persistence.ts";

const projectId = "hq";
const conversationId =
  "matilda-conversation-hq-1789754980083-t80g6h";

const observations = readAtlasHistoricalObservations({
  projectId,
  conversationId,
});

console.log(
  "CURRENT_ATLAS_SCOPED_READBACK=" +
    JSON.stringify(observations, null, 2),
);

console.log(
  `CURRENT_ATLAS_SCOPED_READBACK_COUNT=${observations.length}`,
);
NODE

printf '\n=== CLASSIFY SOURCE-ROW DEPENDENCY WITHOUT MUTATION ===\n'
node <<'NODE'
const fs = require("fs");

const files = [
  "db/atlas-historical-observation-persistence.ts",
  "server/atlas/atlas-historical-observation-adapter.ts",
  "server/atlas/atlas-preexecution-observation-aggregator.ts",
  "server/routes/atlas/preexecution.ts",
];

const content = files
  .filter((file) => fs.existsSync(file))
  .map((file) => fs.readFileSync(file, "utf8"))
  .join("\n");

const directMatildaRuntimeReferences = [
  "matilda-conversation-runtime",
  "matilda-interpretation-runtime",
  "matilda-living-draft-runtime",
].filter((needle) => content.includes(needle));

console.log(
  "DIRECT_MATILDA_RUNTIME_REFERENCES=" +
    JSON.stringify(directMatildaRuntimeReferences),
);

if (directMatildaRuntimeReferences.length === 0) {
  console.log(
    "STATIC_READ_PATH_CLASS=NO_DIRECT_MATILDA_RUNTIME_REFERENCE_FOUND",
  );
  console.log(
    "DELETION_SAFETY=NOT_YET_AUTHORIZED_REQUIRES_ROW_LEVEL_CLASSIFICATION",
  );
} else {
  console.log(
    "STATIC_READ_PATH_CLASS=MATILDA_SOURCE_DEPENDENCY_PRESENT",
  );
  console.log(
    "PREFERRED_CLEANUP_MODEL=RETIRE_OR_HIDE_SOURCE_ROWS_NOT_PHYSICAL_DELETE",
  );
}
NODE

printf '\n=== VERIFY INVESTIGATION WAS READ ONLY ===\n'
test "$(git rev-parse HEAD)" = "$PRE_HEAD"
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  db/main.db \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts \
  server/matilda-chat-workflow.ts \
  client/src/approvals \
  client/src/atlas

printf '\n=== STOPPING POINT ===\n'
echo "DOGFOOD_DEPENDENCY_MAPPING=COMPLETE"
echo "CLEANUP_EXECUTED=NO"
echo "ATLAS_QA_EVIDENCE_DELETED=NO"
echo "DATABASE_MUTATED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "DR_RECOVERY_BOUNDARY=20260918_142139"
echo "NEXT_ACTION=CLASSIFY_EACH_DOGFOOD_ROW_AS_PRESERVE_RETIRE_OR_SAFE_TO_REMOVE"
echo "CLEAR_STOPPING_POINT=YES"
