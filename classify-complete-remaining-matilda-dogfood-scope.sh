#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="b8f24d0c2"
PRE_HEAD="$(git rev-parse HEAD)"
DB="db/main.db"
ATLAS_QA_CONVERSATION="matilda-conversation-hq-1789754980083-t80g6h"
ORPHAN_CONVERSATION="matilda-conversation-hq-1789749528009-03810g"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"
test -f "$DB"

printf '\n=== CORRIDOR STATE ===\n'
echo "MATILDA_DOGFOOD_CLEANUP_CORRIDOR=ACTIVE"
echo "MODE=READ_ONLY_CLASSIFICATION"
echo "CLEANUP_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "PRODUCT_CODE_MUTATION_AUTHORIZED=NO"
echo "APPROVAL_MUTATION_AUTHORIZED=NO"
echo "GOVERNANCE_MUTATION_AUTHORIZED=NO"
echo "AUTHORITY_MUTATION_AUTHORIZED=NO"
echo "ATLAS_QA_ROWS_MUST_REMAIN=2"

node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

const atlasQaConversation =
  "matilda-conversation-hq-1789754980083-t80g6h";

const orphanConversation =
  "matilda-conversation-hq-1789749528009-03810g";

function exists(name) {
  return Boolean(
    db.prepare(`
      SELECT 1
      FROM sqlite_master
      WHERE type = 'table'
        AND name = ?
    `).get(name),
  );
}

function cols(name) {
  return exists(name)
    ? db.prepare(`PRAGMA table_info("${name}")`).all()
        .map((row) => row.name)
    : [];
}

function countForConversation(table, conversationId) {
  if (!exists(table) || !cols(table).includes("conversation_id")) {
    return 0;
  }

  return db.prepare(`
    SELECT COUNT(*)
    FROM "${table}"
    WHERE conversation_id = ?
  `).pluck().get(conversationId);
}

function countProjectRows(table) {
  if (!exists(table)) return 0;

  const names = cols(table);

  if (names.includes("project_id")) {
    return db.prepare(`
      SELECT COUNT(*)
      FROM "${table}"
      WHERE project_id = 'hq'
    `).pluck().get();
  }

  return db.prepare(`
    SELECT COUNT(*)
    FROM "${table}"
  `).pluck().get();
}

try {
  console.log("\n=== IDENTIFY COMPLETE REMAINING CONVERSATION SET ===");

  const sourceTables = [
    "matilda_active_conversation_context",
    "matilda_conversations",
    "matilda_conversation_turns",
    "matilda_interpretation_evidence_ledger",
    "matilda_living_draft_packages",
  ];

  const ids = new Set();

  for (const table of sourceTables) {
    if (!exists(table) || !cols(table).includes("conversation_id")) {
      continue;
    }

    const rows = db.prepare(`
      SELECT DISTINCT conversation_id
      FROM "${table}"
      WHERE project_id = 'hq'
        AND conversation_id IS NOT NULL
        AND trim(conversation_id) <> ''
        AND conversation_id <> ?
    `).all(atlasQaConversation);

    for (const row of rows) {
      ids.add(row.conversation_id);
    }
  }

  const conversationIds = [...ids].sort();

  console.log(
    `REMAINING_SOURCE_CONVERSATIONS=${JSON.stringify(conversationIds)}`,
  );
  console.log(
    `REMAINING_SOURCE_CONVERSATION_COUNT=${conversationIds.length}`,
  );

  console.log("\n=== ROW COUNTS BY CONVERSATION ===");

  let activeContextTotal = 0;
  let conversationTotal = 0;
  let turnTotal = 0;
  let ielTotal = 0;
  let draftTotal = 0;

  for (const conversationId of conversationIds) {
    const active = countForConversation(
      "matilda_active_conversation_context",
      conversationId,
    );
    const conversations = countForConversation(
      "matilda_conversations",
      conversationId,
    );
    const turns = countForConversation(
      "matilda_conversation_turns",
      conversationId,
    );
    const iel = countForConversation(
      "matilda_interpretation_evidence_ledger",
      conversationId,
    );
    const drafts = countForConversation(
      "matilda_living_draft_packages",
      conversationId,
    );

    activeContextTotal += active;
    conversationTotal += conversations;
    turnTotal += turns;
    ielTotal += iel;
    draftTotal += drafts;

    console.log(
      `DOGFOOD_CONVERSATION=${JSON.stringify({
        conversationId,
        activeContext: active,
        conversationRows: conversations,
        turns,
        interpretationEvidence: iel,
        livingDrafts: drafts,
      })}`,
    );
  }

  console.log("\n=== COMPLETE CANDIDATE TOTALS ===");
  console.log(`CANDIDATE_ACTIVE_CONTEXT_ROWS=${activeContextTotal}`);
  console.log(`CANDIDATE_CONVERSATION_ROWS=${conversationTotal}`);
  console.log(`CANDIDATE_TURN_ROWS=${turnTotal}`);
  console.log(`CANDIDATE_IEL_ROWS=${ielTotal}`);
  console.log(`CANDIDATE_LIVING_DRAFT_ROWS=${draftTotal}`);
  console.log(
    `CANDIDATE_TOTAL_ROWS=${
      activeContextTotal +
      conversationTotal +
      turnTotal +
      ielTotal +
      draftTotal
    }`,
  );

  console.log("\n=== ORPHAN LEDGER CLASSIFICATION ===");

  const orphan = exists("matilda_interpretation_evidence_ledger")
    ? db.prepare(`
        SELECT *
        FROM matilda_interpretation_evidence_ledger
        WHERE project_id = 'hq'
          AND conversation_id = ?
      `).all(orphanConversation)
    : [];

  console.log(`ORPHAN_IEL_COUNT=${orphan.length}`);

  for (const row of orphan) {
    console.log(`ORPHAN_IEL_ROW=${JSON.stringify(row)}`);
  }

  console.log(
    `ORPHAN_HAS_CONVERSATION_ROW=${
      countForConversation(
        "matilda_conversations",
        orphanConversation,
      ) > 0 ? "YES" : "NO"
    }`,
  );

  console.log(
    `ORPHAN_HAS_TURN_ROW=${
      countForConversation(
        "matilda_conversation_turns",
        orphanConversation,
      ) > 0 ? "YES" : "NO"
    }`,
  );

  console.log(
    `ORPHAN_HAS_LIVING_DRAFT=${
      countForConversation(
        "matilda_living_draft_packages",
        orphanConversation,
      ) > 0 ? "YES" : "NO"
    }`,
  );

  console.log("\n=== ATLAS PRESERVATION BOUNDARY ===");

  const atlasRows = db.prepare(`
    SELECT
      observation_id,
      source_kind,
      source_identity,
      project_id,
      conversation_id,
      lineage_id,
      authority_status
    FROM atlas_historical_observations
    WHERE project_id = 'hq'
      AND conversation_id = ?
    ORDER BY observation_id
  `).all(atlasQaConversation);

  console.log(`ATLAS_QA_ROW_COUNT=${atlasRows.length}`);

  for (const row of atlasRows) {
    console.log(`PRESERVE_ATLAS_QA=${JSON.stringify(row)}`);
  }

  if (atlasRows.length !== 2) {
    throw new Error(
      `Atlas QA preservation boundary violated: expected 2 rows, found ${atlasRows.length}`,
    );
  }

  const atlasCandidateRefs = conversationIds
    .map((conversationId) => ({
      conversationId,
      count: db.prepare(`
        SELECT COUNT(*)
        FROM atlas_historical_observations
        WHERE project_id = 'hq'
          AND conversation_id = ?
      `).pluck().get(conversationId),
    }))
    .filter((item) => item.count > 0);

  console.log(
    `ATLAS_REFERENCES_TO_CLEANUP_CANDIDATES=${JSON.stringify(atlasCandidateRefs)}`,
  );

  console.log("\n=== CANONICAL / GOVERNANCE REFERENCE CHECK ===");

  const protectedTables = db.prepare(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND (
        lower(name) LIKE '%canonical%'
        OR lower(name) LIKE 'governance_%'
      )
    ORDER BY name
  `).all().map((row) => row.name);

  let protectedReferenceCount = 0;

  for (const table of protectedTables) {
    const names = cols(table);

    if (!names.includes("conversation_id")) {
      console.log(
        `PROTECTED_TABLE=${table} CONVERSATION_REFERENCE_COLUMN=NO PROJECT_ROWS=${countProjectRows(table)}`,
      );
      continue;
    }

    const placeholders = conversationIds.map(() => "?").join(",");

    if (!placeholders) continue;

    const rows = db.prepare(`
      SELECT COUNT(*)
      FROM "${table}"
      WHERE conversation_id IN (${placeholders})
    `).pluck().get(...conversationIds);

    protectedReferenceCount += rows;

    console.log(
      `PROTECTED_TABLE=${table} CLEANUP_CANDIDATE_REFERENCES=${rows}`,
    );
  }

  console.log(
    `CANONICAL_GOVERNANCE_CANDIDATE_REFERENCE_COUNT=${protectedReferenceCount}`,
  );

  console.log("\n=== CLASSIFICATION ===");

  if (
    atlasCandidateRefs.length === 0 &&
    protectedReferenceCount === 0 &&
    atlasRows.length === 2
  ) {
    console.log(
      "REMAINING_MATILDA_DOGFOOD_CLASS=BOUNDED_SOURCE_ROWS_APPEAR_REMOVABLE",
    );
    console.log(
      "ATLAS_QA_PRESERVATION_CLASS=INDEPENDENT_AND_UNTOUCHED",
    );
    console.log(
      "NEXT_GATE=EXPLICIT_BOUNDED_REMOVAL_AUTHORIZATION_REQUIRED",
    );
  } else {
    console.log(
      "REMAINING_MATILDA_DOGFOOD_CLASS=REFERENCES_REQUIRE_FURTHER_REVIEW",
    );
    console.log(
      "NEXT_GATE=DO_NOT_AUTHORIZE_REMOVAL_YET",
    );
  }
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY READ ONLY ===\n'
test "$(git rev-parse HEAD)" = "$PRE_HEAD"
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  db/main.db \
  db/atlas-historical-observation-persistence.ts \
  server/atlas \
  server/matilda-chat-workflow.ts \
  client/src/atlas \
  client/src/approvals

printf '\n=== STOPPING POINT ===\n'
echo "MATILDA_DOGFOOD_CLEANUP_EXECUTED=NO"
echo "ATLAS_QA_EVIDENCE_DELETED=NO"
echo "DATABASE_MUTATED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "GOVERNANCE_MUTATION=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=USE_CLASSIFICATION_TO_DEFINE_EXACT_FINAL_REMOVAL_BOUNDARY"
echo "CLEAR_STOPPING_POINT=YES"
