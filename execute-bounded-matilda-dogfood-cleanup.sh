#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="96a1116bb"
DB="db/main.db"
CONVERSATION_ID="matilda-conversation-hq-1789754980083-t80g6h"
DRAFT_ID="matilda-draft-matilda-conversation-hq-1789754980083-t80g6h"
IEL_ID="iel-chat-1789755021093-cjj4uj"
DR_BOUNDARY="20260918_142139"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"
test -f "$DB"

printf '\n=== AUTHORIZED BOUNDARY ===\n'
echo "AUTHORIZED_OPERATION=BOUNDED_MATILDA_DOGFOOD_ROW_REMOVAL"
echo "AUTHORIZED_CONVERSATION=$CONVERSATION_ID"
echo "AUTHORIZED_MATILDA_ROWS=5"
echo "ATLAS_QA_ROWS_MUST_REMAIN=2"
echo "PRODUCT_CODE_MUTATION_AUTHORIZED=NO"
echo "APPROVAL_MUTATION_AUTHORIZED=NO"
echo "GOVERNANCE_MUTATION_AUTHORIZED=NO"
echo "AUTHORITY_MUTATION_AUTHORIZED=NO"
echo "DR_RECOVERY_BOUNDARY=$DR_BOUNDARY"

printf '\n=== PRE-MUTATION SAFETY CHECK ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

const conversationId =
  "matilda-conversation-hq-1789754980083-t80g6h";
const draftId =
  "matilda-draft-matilda-conversation-hq-1789754980083-t80g6h";
const ielId =
  "iel-chat-1789755021093-cjj4uj";

try {
  const scalar = (sql, ...params) =>
    db.prepare(sql).get(...params).count;

  const counts = {
    activeContext: scalar(
      `SELECT COUNT(*) AS count
       FROM matilda_active_conversation_context
       WHERE conversation_id = ?`,
      conversationId,
    ),
    turns: scalar(
      `SELECT COUNT(*) AS count
       FROM matilda_conversation_turns
       WHERE conversation_id = ?`,
      conversationId,
    ),
    conversations: scalar(
      `SELECT COUNT(*) AS count
       FROM matilda_conversations
       WHERE conversation_id = ?`,
      conversationId,
    ),
    iel: scalar(
      `SELECT COUNT(*) AS count
       FROM matilda_interpretation_evidence_ledger
       WHERE conversation_id = ?`,
      conversationId,
    ),
    drafts: scalar(
      `SELECT COUNT(*) AS count
       FROM matilda_living_draft_packages
       WHERE conversation_id = ?`,
      conversationId,
    ),
    revisions: scalar(
      `SELECT COUNT(*) AS count
       FROM matilda_draft_revisions
       WHERE conversation_id = ?
          OR draft_package_id = ?`,
      conversationId,
      draftId,
    ),
    canonical: scalar(
      `SELECT COUNT(*) AS count
       FROM matilda_canonical_packages
       WHERE conversation_id = ?
          OR draft_package_id = ?`,
      conversationId,
      draftId,
    ),
    governance: scalar(
      `SELECT COUNT(*) AS count
       FROM governance_packages
       WHERE conversation_id = ?`,
      conversationId,
    ),
    atlas: scalar(
      `SELECT COUNT(*) AS count
       FROM atlas_historical_observations
       WHERE project_id = 'hq'
         AND conversation_id = ?`,
      conversationId,
    ),
  };

  console.log(`PRE_ACTIVE_CONTEXT=${counts.activeContext}`);
  console.log(`PRE_TURNS=${counts.turns}`);
  console.log(`PRE_CONVERSATIONS=${counts.conversations}`);
  console.log(`PRE_IEL=${counts.iel}`);
  console.log(`PRE_DRAFTS=${counts.drafts}`);
  console.log(`PRE_DRAFT_REVISIONS=${counts.revisions}`);
  console.log(`PRE_CANONICAL=${counts.canonical}`);
  console.log(`PRE_GOVERNANCE=${counts.governance}`);
  console.log(`PRE_ATLAS=${counts.atlas}`);

  if (
    counts.activeContext !== 1 ||
    counts.turns !== 1 ||
    counts.conversations !== 1 ||
    counts.iel !== 1 ||
    counts.drafts !== 1
  ) {
    throw new Error(
      "Authorized five-row Matilda boundary has drifted; refusing cleanup.",
    );
  }

  if (
    counts.revisions !== 0 ||
    counts.canonical !== 0 ||
    counts.governance !== 0
  ) {
    throw new Error(
      "Downstream dependency appeared; refusing cleanup.",
    );
  }

  if (counts.atlas !== 2) {
    throw new Error(
      `Expected exactly 2 Atlas QA rows; received ${counts.atlas}.`,
    );
  }

  const atlasPayloads = db.prepare(`
    SELECT payload_json
    FROM atlas_historical_observations
    WHERE project_id = 'hq'
      AND conversation_id = ?
    ORDER BY observation_id
  `).all(conversationId);

  const serialized = JSON.stringify(atlasPayloads);

  if (
    !serialized.includes(ielId) ||
    !serialized.includes(draftId)
  ) {
    throw new Error(
      "Atlas persisted QA copies do not contain expected source identities.",
    );
  }

  console.log("PRE_MUTATION_BOUNDARY=PASS");
  console.log("ATLAS_INDEPENDENT_QA_COPY=CONFIRMED");
} finally {
  db.close();
}
NODE

printf '\n=== SNAPSHOT AUTHORIZED DATABASE ===\n'
cp "$DB" "/tmp/main.db.pre-matilda-dogfood-cleanup.$$"
echo "LOCAL_PRE_MUTATION_DB_SNAPSHOT=CREATED"

printf '\n=== EXECUTE EXACT FIVE-ROW CLEANUP ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  fileMustExist: true,
});

const conversationId =
  "matilda-conversation-hq-1789754980083-t80g6h";

const cleanup = db.transaction(() => {
  const results = [];

  results.push([
    "active_context",
    db.prepare(`
      DELETE FROM matilda_active_conversation_context
      WHERE conversation_id = ?
    `).run(conversationId).changes,
  ]);

  results.push([
    "turn",
    db.prepare(`
      DELETE FROM matilda_conversation_turns
      WHERE conversation_id = ?
    `).run(conversationId).changes,
  ]);

  results.push([
    "iel",
    db.prepare(`
      DELETE FROM matilda_interpretation_evidence_ledger
      WHERE conversation_id = ?
    `).run(conversationId).changes,
  ]);

  results.push([
    "living_draft",
    db.prepare(`
      DELETE FROM matilda_living_draft_packages
      WHERE conversation_id = ?
    `).run(conversationId).changes,
  ]);

  results.push([
    "conversation",
    db.prepare(`
      DELETE FROM matilda_conversations
      WHERE conversation_id = ?
    `).run(conversationId).changes,
  ]);

  for (const [name, changes] of results) {
    if (changes !== 1) {
      throw new Error(
        `Expected exactly one ${name} row removal; received ${changes}.`,
      );
    }
  }

  return results;
});

try {
  const results = cleanup();

  for (const [name, changes] of results) {
    console.log(
      `REMOVED_${name.toUpperCase()}_ROWS=${changes}`,
    );
  }

  console.log("AUTHORIZED_ROWS_REMOVED=5");
  console.log("CLEANUP_TRANSACTION=COMMITTED");
} finally {
  db.close();
}
NODE

printf '\n=== POST-MUTATION PROOF ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

const conversationId =
  "matilda-conversation-hq-1789754980083-t80g6h";

try {
  const checks = [
    ["ACTIVE_CONTEXT", "matilda_active_conversation_context"],
    ["TURNS", "matilda_conversation_turns"],
    ["CONVERSATIONS", "matilda_conversations"],
    ["IEL", "matilda_interpretation_evidence_ledger"],
    ["DRAFTS", "matilda_living_draft_packages"],
  ];

  for (const [label, table] of checks) {
    const row = db.prepare(`
      SELECT COUNT(*) AS count
      FROM ${table}
      WHERE conversation_id = ?
    `).get(conversationId);

    console.log(`POST_${label}=${row.count}`);

    if (row.count !== 0) {
      throw new Error(
        `${table} still contains authorized dogfood rows.`,
      );
    }
  }

  const atlasRows = db.prepare(`
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

  console.log(`POST_ATLAS_QA_ROWS=${atlasRows.length}`);

  if (atlasRows.length !== 2) {
    throw new Error(
      `Atlas QA evidence changed unexpectedly: ${atlasRows.length} rows.`,
    );
  }

  for (const row of atlasRows) {
    console.log(
      `PRESERVED_ATLAS_QA=${JSON.stringify(row)}`,
    );
  }

  const integrity =
    db.prepare("PRAGMA integrity_check").pluck().get();

  console.log(`DATABASE_INTEGRITY=${integrity}`);

  if (integrity !== "ok") {
    throw new Error(
      `Database integrity check failed: ${integrity}`,
    );
  }

  console.log("MATILDA_COLLABORATION_DOGFOOD_REMOVED=YES");
  console.log("ATLAS_QA_EVIDENCE_PRESERVED=YES");
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY MUTATION SCOPE ===\n'
git diff --exit-code -- \
  db/atlas-historical-observation-persistence.ts \
  server/atlas \
  server/matilda-chat-workflow.ts \
  client/src/atlas \
  client/src/approvals

CHANGED="$(git diff --name-only)"

if [ "$CHANGED" != "db/main.db" ]; then
  echo "Unexpected tracked mutation set:"
  printf '%s\n' "$CHANGED"
  exit 1
fi

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "MATILDA_DOGFOOD_CLEANUP=EXECUTED"
echo "AUTHORIZED_ROWS_REMOVED=5"
echo "ATLAS_QA_ROWS_PRESERVED=2"
echo "ATLAS_QA_EVIDENCE_DELETED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "APPROVAL_DECISION_EXECUTED=NO"
echo "GOVERNANCE_MUTATION=NO"
echo "AUTHORITY_CHANGE=NO"
echo "DR_RECOVERY_BOUNDARY=$DR_BOUNDARY"
echo "NEXT_ACTION=VERIFY_ATLAS_READBACK_AFTER_SOURCE_REMOVAL"
echo "CLEAR_STOPPING_POINT=YES"
