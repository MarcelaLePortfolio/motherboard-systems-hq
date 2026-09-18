#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
PRE_HEAD="$(git rev-parse HEAD)"
DB="db/main.db"
PRESERVED_ATLAS_CONVERSATION="matilda-conversation-hq-1789754980083-t80g6h"

printf '\n=== CORRECTED CORRIDOR STATE ===\n'
echo "MATILDA_DOGFOOD_CLEANUP_CORRIDOR=ACTIVE"
echo "PREVIOUS_CLOSURE_CLASSIFICATION=PREMATURE"
echo "PREVIOUSLY_REMOVED_SCOPE=ONE_SPECIFIC_DOGFOOD_CONVERSATION_ONLY"
echo "VISIBLE_MATILDA_COLLABORATION_DOGFOOD=REPORTED_PRESENT"
echo "ATLAS_QA_ROWS_MUST_REMAIN=2"
echo "CLEANUP_AUTHORIZED_BY_THIS_STEP=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "PRODUCT_CODE_MUTATION_AUTHORIZED=NO"
echo "APPROVAL_MUTATION_AUTHORIZED=NO"
echo "GOVERNANCE_MUTATION_AUTHORIZED=NO"
echo "AUTHORITY_MUTATION_AUTHORIZED=NO"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test -f "$DB"
test -z "$(git diff --cached --name-only)"

printf '\n=== INVENTORY REMAINING MATILDA COLLABORATION STATE ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

function tableExists(name) {
  return Boolean(
    db.prepare(`
      SELECT 1
      FROM sqlite_master
      WHERE type = 'table'
        AND name = ?
    `).get(name),
  );
}

function columns(name) {
  return db.prepare(`PRAGMA table_info("${name}")`).all()
    .map((row) => row.name);
}

function selectUsefulRows(table) {
  if (!tableExists(table)) {
    console.log(`${table.toUpperCase()}_PRESENT=NO`);
    return;
  }

  const cols = columns(table);
  const preferred = [
    "project_id",
    "conversation_id",
    "turn_id",
    "entry_id",
    "draft_package_id",
    "approval_request_id",
    "request_id",
    "lineage_id",
    "status",
    "source_status",
    "current_interpretation",
    "user_message",
    "assistant_message",
    "content",
    "created_at",
    "updated_at",
  ].filter((name) => cols.includes(name));

  const selected = preferred.length
    ? preferred.map((name) => `"${name}"`).join(", ")
    : "*";

  const order =
    cols.includes("created_at")
      ? ' ORDER BY "created_at" ASC'
      : cols.includes("updated_at")
        ? ' ORDER BY "updated_at" ASC'
        : "";

  const rows = db.prepare(
    `SELECT ${selected} FROM "${table}"${order}`,
  ).all();

  console.log(`${table.toUpperCase()}_PRESENT=YES`);
  console.log(`${table.toUpperCase()}_ROW_COUNT=${rows.length}`);

  for (const row of rows) {
    console.log(
      `${table.toUpperCase()}_ROW=${JSON.stringify(row)}`,
    );
  }
}

try {
  const tables = [
    "matilda_active_conversation_context",
    "matilda_conversations",
    "matilda_conversation_turns",
    "matilda_interpretation_evidence_ledger",
    "matilda_living_draft_packages",
    "matilda_living_draft_revisions",
    "matilda_canonical_packages",
  ];

  for (const table of tables) {
    console.log(`\n--- ${table} ---`);
    selectUsefulRows(table);
  }

  console.log("\n=== APPROVAL-RELATED TABLE DISCOVERY ===");

  const approvalTables = db.prepare(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND (
        lower(name) LIKE '%approval%'
        OR lower(name) LIKE '%request%'
      )
    ORDER BY name
  `).all();

  console.log(
    `APPROVAL_RELATED_TABLES=${JSON.stringify(
      approvalTables.map((row) => row.name),
    )}`,
  );

  for (const { name } of approvalTables) {
    console.log(`\n--- ${name} ---`);
    selectUsefulRows(name);
  }

  console.log("\n=== PRESERVED ATLAS QA BOUNDARY ===");

  if (!tableExists("atlas_historical_observations")) {
    throw new Error(
      "atlas_historical_observations table is missing",
    );
  }

  const preserved = db.prepare(`
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
  `).all(
    "matilda-conversation-hq-1789754980083-t80g6h",
  );

  console.log(`ATLAS_QA_PRESERVED_ROW_COUNT=${preserved.length}`);

  for (const row of preserved) {
    console.log(
      `PRESERVE_ATLAS_QA=${JSON.stringify(row)}`,
    );
  }

  if (preserved.length !== 2) {
    throw new Error(
      `Expected exactly 2 preserved Atlas QA rows, found ${preserved.length}`,
    );
  }

  console.log("ATLAS_QA_PRESERVATION_BOUNDARY=PASS");

  console.log("\n=== CONVERSATION SUMMARY ===");

  const summaryTables = [
    "matilda_conversations",
    "matilda_conversation_turns",
    "matilda_interpretation_evidence_ledger",
    "matilda_living_draft_packages",
  ].filter(tableExists);

  const ids = new Set();

  for (const table of summaryTables) {
    const cols = columns(table);

    if (!cols.includes("conversation_id")) {
      continue;
    }

    for (const row of db.prepare(`
      SELECT DISTINCT conversation_id
      FROM "${table}"
      WHERE conversation_id IS NOT NULL
        AND trim(conversation_id) <> ''
    `).all()) {
      ids.add(row.conversation_id);
    }
  }

  console.log(
    `REMAINING_MATILDA_CONVERSATION_IDS=${JSON.stringify(
      [...ids].sort(),
    )}`,
  );

  console.log(
    `REMAINING_MATILDA_CONVERSATION_COUNT=${ids.size}`,
  );

  console.log(
    "DOGFOOD_SCOPE_REQUIRES_ROW_LEVEL_CLASSIFICATION=YES",
  );
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY INVESTIGATION IS READ ONLY ===\n'
test "$(git rev-parse HEAD)" = "$PRE_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "MATILDA_DOGFOOD_CLEANUP_CORRIDOR=ACTIVE"
echo "ALL_DOGFOOD_REMOVED=NOT_PROVEN"
echo "VISIBLE_DOGFOOD_REPORT=VALIDATED_AS_REASON_TO_CONTINUE_INVESTIGATION"
echo "ATLAS_QA_EVIDENCE_DELETED=NO"
echo "DATABASE_MUTATED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "GOVERNANCE_MUTATION=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=CLASSIFY_REMAINING_ROWS_FROM_INVENTORY_BEFORE_ANY_FURTHER_REMOVAL"
echo "CLEAR_STOPPING_POINT=YES"
