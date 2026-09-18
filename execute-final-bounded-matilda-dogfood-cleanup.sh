#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="44b2ef6797e1472fb8ac667a5383b4475e7a39f0"
DB="db/main.db"
ATLAS_QA_CONVERSATION="matilda-conversation-hq-1789754980083-t80g6h"

DOGFOOD_CONVERSATIONS=(
  "matilda-conversation-hq"
  "matilda-conversation-hq-1789422346359-tetjdh"
  "matilda-conversation-hq-1789423843818-711pwh"
  "matilda-conversation-hq-1789492831113-lazy9u"
  "matilda-conversation-hq-1789494445507-0xnsh6"
  "matilda-conversation-hq-1789505801681-8ter2b"
  "matilda-conversation-hq-1789507062555-ldkiv8"
  "matilda-conversation-hq-1789749528009-03810g"
)

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"
test -f "$DB"

printf '\n=== AUTHORIZED FINAL BOUNDARY ===\n'
echo "AUTHORIZED_OPERATION=BOUNDED_FINAL_MATILDA_DOGFOOD_REMOVAL"
echo "AUTHORIZED_CLASSIFICATION_HEAD=$EXPECTED_HEAD"
echo "AUTHORIZED_CONVERSATION_COUNT=8"
echo "AUTHORIZED_ROW_COUNT=62"
echo "ATLAS_QA_CONVERSATION=$ATLAS_QA_CONVERSATION"
echo "ATLAS_QA_ROWS_MUST_REMAIN=2"
echo "PRODUCT_CODE_MUTATION_AUTHORIZED=NO"
echo "APPROVAL_MUTATION_AUTHORIZED=NO"
echo "CANONICAL_MUTATION_AUTHORIZED=NO"
echo "GOVERNANCE_MUTATION_AUTHORIZED=NO"
echo "EXECUTION_MUTATION_AUTHORIZED=NO"
echo "AUTHORITY_MUTATION_AUTHORIZED=NO"

printf '\n=== CREATE LOCAL DATABASE SAFETY SNAPSHOT ===\n'
cp "$DB" "/tmp/main.db.pre-final-matilda-dogfood-cleanup.$(date +%Y%m%d_%H%M%S)"
echo "LOCAL_PRE_MUTATION_DB_SNAPSHOT=CREATED"

printf '\n=== EXECUTE EXACT AUTHORIZED TRANSACTION ===\n'

node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", { fileMustExist: true });

const atlasQaConversation =
  "matilda-conversation-hq-1789754980083-t80g6h";

const conversationIds = [
  "matilda-conversation-hq",
  "matilda-conversation-hq-1789422346359-tetjdh",
  "matilda-conversation-hq-1789423843818-711pwh",
  "matilda-conversation-hq-1789492831113-lazy9u",
  "matilda-conversation-hq-1789494445507-0xnsh6",
  "matilda-conversation-hq-1789505801681-8ter2b",
  "matilda-conversation-hq-1789507062555-ldkiv8",
  "matilda-conversation-hq-1789749528009-03810g",
];

const expected = {
  active: 1,
  conversations: 7,
  turns: 23,
  iel: 24,
  drafts: 7,
};

const placeholders = conversationIds.map(() => "?").join(",");

function count(table) {
  return db.prepare(`
    SELECT COUNT(*)
    FROM "${table}"
    WHERE conversation_id IN (${placeholders})
  `).pluck().get(...conversationIds);
}

function atlasQaCount() {
  return db.prepare(`
    SELECT COUNT(*)
    FROM atlas_historical_observations
    WHERE project_id = 'hq'
      AND conversation_id = ?
  `).pluck().get(atlasQaConversation);
}

function atlasCandidateReferenceCount() {
  return db.prepare(`
    SELECT COUNT(*)
    FROM atlas_historical_observations
    WHERE conversation_id IN (${placeholders})
  `).pluck().get(...conversationIds);
}

function protectedReferenceCount() {
  let total = 0;

  const tables = db.prepare(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND (
        lower(name) LIKE '%canonical%'
        OR lower(name) LIKE 'governance_%'
      )
    ORDER BY name
  `).all();

  for (const { name } of tables) {
    const columns = db
      .prepare(`PRAGMA table_info("${name}")`)
      .all()
      .map((row) => row.name);

    if (!columns.includes("conversation_id")) continue;

    total += db.prepare(`
      SELECT COUNT(*)
      FROM "${name}"
      WHERE conversation_id IN (${placeholders})
    `).pluck().get(...conversationIds);
  }

  return total;
}

try {
  const pre = {
    active: count("matilda_active_conversation_context"),
    conversations: count("matilda_conversations"),
    turns: count("matilda_conversation_turns"),
    iel: count("matilda_interpretation_evidence_ledger"),
    drafts: count("matilda_living_draft_packages"),
  };

  const preTotal = Object.values(pre).reduce((a, b) => a + b, 0);

  console.log(`PRE_BOUNDARY=${JSON.stringify(pre)}`);
  console.log(`PRE_AUTHORIZED_TOTAL=${preTotal}`);

  if (
    pre.active !== expected.active ||
    pre.conversations !== expected.conversations ||
    pre.turns !== expected.turns ||
    pre.iel !== expected.iel ||
    pre.drafts !== expected.drafts ||
    preTotal !== 62
  ) {
    throw new Error(
      `AUTHORIZED_BOUNDARY_DRIFT=${JSON.stringify(pre)}`
    );
  }

  if (atlasQaCount() !== 2) {
    throw new Error("ATLAS_QA_BOUNDARY_DRIFT");
  }

  if (atlasCandidateReferenceCount() !== 0) {
    throw new Error("ATLAS_NOW_REFERENCES_CLEANUP_CANDIDATES");
  }

  if (protectedReferenceCount() !== 0) {
    throw new Error("CANONICAL_OR_GOVERNANCE_REFERENCE_DRIFT");
  }

  console.log("PRE_MUTATION_BOUNDARY=PASS");
  console.log("ATLAS_INDEPENDENT_QA_COPY=CONFIRMED");

  const cleanup = db.transaction(() => {
    const active = db.prepare(`
      DELETE FROM matilda_active_conversation_context
      WHERE conversation_id IN (${placeholders})
    `).run(...conversationIds).changes;

    const turns = db.prepare(`
      DELETE FROM matilda_conversation_turns
      WHERE conversation_id IN (${placeholders})
    `).run(...conversationIds).changes;

    const iel = db.prepare(`
      DELETE FROM matilda_interpretation_evidence_ledger
      WHERE conversation_id IN (${placeholders})
    `).run(...conversationIds).changes;

    const drafts = db.prepare(`
      DELETE FROM matilda_living_draft_packages
      WHERE conversation_id IN (${placeholders})
    `).run(...conversationIds).changes;

    const conversations = db.prepare(`
      DELETE FROM matilda_conversations
      WHERE conversation_id IN (${placeholders})
    `).run(...conversationIds).changes;

    const total = active + turns + iel + drafts + conversations;

    if (
      active !== 1 ||
      turns !== 23 ||
      iel !== 24 ||
      drafts !== 7 ||
      conversations !== 7 ||
      total !== 62
    ) {
      throw new Error(
        `REMOVAL_COUNT_MISMATCH=${JSON.stringify({
          active,
          turns,
          iel,
          drafts,
          conversations,
          total,
        })}`
      );
    }

    if (atlasQaCount() !== 2) {
      throw new Error("ATLAS_QA_CHANGED_DURING_TRANSACTION");
    }

    return { active, turns, iel, drafts, conversations, total };
  });

  const removed = cleanup();

  console.log(`REMOVED=${JSON.stringify(removed)}`);
  console.log("CLEANUP_TRANSACTION=COMMITTED");

  const postTotal =
    count("matilda_active_conversation_context") +
    count("matilda_conversations") +
    count("matilda_conversation_turns") +
    count("matilda_interpretation_evidence_ledger") +
    count("matilda_living_draft_packages");

  console.log(`POST_AUTHORIZED_SOURCE_ROWS=${postTotal}`);

  if (postTotal !== 0) {
    throw new Error(`AUTHORIZED_ROWS_REMAIN=${postTotal}`);
  }

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

  if (atlasRows.length !== 2) {
    throw new Error(`ATLAS_QA_ROWS=${atlasRows.length}`);
  }

  for (const row of atlasRows) {
    console.log(`PRESERVED_ATLAS_QA=${JSON.stringify(row)}`);
  }

  const integrity =
    db.prepare("PRAGMA integrity_check").pluck().get();

  console.log(`DATABASE_INTEGRITY=${integrity}`);

  if (integrity !== "ok") {
    throw new Error(`DATABASE_INTEGRITY_FAILURE=${integrity}`);
  }

  console.log("AUTHORIZED_ROWS_REMOVED=62");
  console.log("MATILDA_REMAINING_DOGFOOD_REMOVAL=PASS");
  console.log("ATLAS_QA_ROWS_PRESERVED=2");
  console.log("ATLAS_QA_EVIDENCE_DELETED=NO");
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY PROTECTED PRODUCT PATHS ===\n'
git diff --exit-code -- \
  db/atlas-historical-observation-persistence.ts \
  server/atlas \
  server/matilda-chat-workflow.ts \
  client/src/atlas \
  client/src/approvals

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "MATILDA_DOGFOOD_CLEANUP=EXECUTED"
echo "AUTHORIZED_REMAINING_ROWS_REMOVED=62"
echo "ATLAS_QA_ROWS_PRESERVED=2"
echo "ATLAS_QA_EVIDENCE_DELETED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "CANONICAL_MUTATION=NO"
echo "GOVERNANCE_MUTATION=NO"
echo "EXECUTION_MUTATION=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=VERIFY_COMPLETE_MATILDA_DOGFOOD_ABSENCE_AND_ATLAS_LIVE_READBACK"
echo "CLEAR_STOPPING_POINT=YES"
