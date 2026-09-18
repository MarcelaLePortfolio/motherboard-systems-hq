#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="241ea4cfb"
DOGFOOD_CONVERSATION_ID="matilda-conversation-hq-1789754980083-t80g6h"
DOGFOOD_DRAFT_ID="matilda-draft-matilda-conversation-hq-1789754980083-t80g6h"
DOGFOOD_IEL_ID="iel-chat-1789755021093-cjj4uj"
DB="db/main.db"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"
test -f "$DB"

PRE_HEAD="$(git rev-parse HEAD)"

printf '\n=== ESTABLISHED PRESERVATION BOUNDARY ===\n'
echo "ATLAS_HISTORICAL_ROWS_TO_PRESERVE=2"
echo "ATLAS_QA_EVIDENCE_DELETION_AUTHORIZED=NO"
echo "MATILDA_ROWS_TO_CLASSIFY=5"
echo "CLEANUP_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== CLASSIFY FIVE NON-ATLAS MATILDA ROWS ===\n'
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
  const activeContext = db.prepare(`
    SELECT *
    FROM matilda_active_conversation_context
    WHERE conversation_id = ?
  `).all(conversationId);

  const turns = db.prepare(`
    SELECT *
    FROM matilda_conversation_turns
    WHERE conversation_id = ?
  `).all(conversationId);

  const conversations = db.prepare(`
    SELECT *
    FROM matilda_conversations
    WHERE conversation_id = ?
  `).all(conversationId);

  const iel = db.prepare(`
    SELECT *
    FROM matilda_interpretation_evidence_ledger
    WHERE conversation_id = ?
  `).all(conversationId);

  const drafts = db.prepare(`
    SELECT *
    FROM matilda_living_draft_packages
    WHERE conversation_id = ?
  `).all(conversationId);

  console.log(`ACTIVE_CONTEXT_ROWS=${activeContext.length}`);
  console.log(`CONVERSATION_TURN_ROWS=${turns.length}`);
  console.log(`CONVERSATION_ROWS=${conversations.length}`);
  console.log(`IEL_ROWS=${iel.length}`);
  console.log(`LIVING_DRAFT_ROWS=${drafts.length}`);

  const revisionRefs = db.prepare(`
    SELECT *
    FROM matilda_draft_revisions
    WHERE conversation_id = ?
       OR draft_package_id = ?
  `).all(conversationId, draftId);

  const canonicalRefs = db.prepare(`
    SELECT *
    FROM matilda_canonical_packages
    WHERE conversation_id = ?
       OR draft_package_id = ?
  `).all(conversationId, draftId);

  const governancePackageRefs = db.prepare(`
    SELECT *
    FROM governance_packages
    WHERE conversation_id = ?
  `).all(conversationId);

  console.log(
    `DRAFT_REVISION_REFERENCES=${revisionRefs.length}`,
  );
  console.log(
    `CANONICAL_PACKAGE_REFERENCES=${canonicalRefs.length}`,
  );
  console.log(
    `GOVERNANCE_PACKAGE_REFERENCES=${governancePackageRefs.length}`,
  );

  const atlasRows = db.prepare(`
    SELECT observation_id, source_kind, source_identity
    FROM atlas_historical_observations
    WHERE project_id = 'hq'
      AND conversation_id = ?
    ORDER BY observation_id
  `).all(conversationId);

  console.log(
    `ATLAS_PRESERVED_ROWS=${atlasRows.length}`,
  );

  if (atlasRows.length !== 2) {
    throw new Error(
      `Expected 2 Atlas preserved rows, received ${atlasRows.length}`,
    );
  }

  const atlasPayloads = db.prepare(`
    SELECT payload_json
    FROM atlas_historical_observations
    WHERE project_id = 'hq'
      AND conversation_id = ?
  `).all(conversationId);

  const atlasSerialized = JSON.stringify(atlasPayloads);

  console.log(
    `ATLAS_CONTAINS_IEL_PAYLOAD=${
      atlasSerialized.includes(ielId) ? "YES" : "NO"
    }`,
  );

  console.log(
    `ATLAS_CONTAINS_DRAFT_PAYLOAD=${
      atlasSerialized.includes(draftId) ? "YES" : "NO"
    }`,
  );

  console.log("\n=== ROW CLASSIFICATION ===");

  if (activeContext.length === 1) {
    console.log(
      "matilda_active_conversation_context=REMOVE_OR_REPOINT_CANDIDATE",
    );
    console.log(
      "REASON_ACTIVE_CONTEXT=UI_NAVIGATION_STATE_NOT_ATLAS_QA_SOURCE",
    );
  }

  if (
    turns.length === 1 &&
    revisionRefs.length === 0 &&
    canonicalRefs.length === 0 &&
    governancePackageRefs.length === 0
  ) {
    console.log(
      "matilda_conversation_turns=SAFE_REMOVE_CANDIDATE_PENDING_FINAL_AUTHORIZATION",
    );
  } else {
    console.log(
      "matilda_conversation_turns=PRESERVE_OR_RETIRE_PENDING_DEPENDENCY_REVIEW",
    );
  }

  if (
    conversations.length === 1 &&
    revisionRefs.length === 0 &&
    canonicalRefs.length === 0 &&
    governancePackageRefs.length === 0
  ) {
    console.log(
      "matilda_conversations=SAFE_REMOVE_CANDIDATE_AFTER_CHILD_ROWS",
    );
  } else {
    console.log(
      "matilda_conversations=PRESERVE_OR_RETIRE_PENDING_DEPENDENCY_REVIEW",
    );
  }

  if (
    iel.length === 1 &&
    revisionRefs.length === 0 &&
    canonicalRefs.length === 0 &&
    governancePackageRefs.length === 0 &&
    atlasSerialized.includes(ielId)
  ) {
    console.log(
      "matilda_interpretation_evidence_ledger=SAFE_REMOVE_CANDIDATE_ATLAS_COPY_PRESERVED",
    );
  } else {
    console.log(
      "matilda_interpretation_evidence_ledger=PRESERVE_OR_RETIRE_PENDING_DEPENDENCY_REVIEW",
    );
  }

  if (
    drafts.length === 1 &&
    revisionRefs.length === 0 &&
    canonicalRefs.length === 0 &&
    governancePackageRefs.length === 0 &&
    atlasSerialized.includes(draftId)
  ) {
    console.log(
      "matilda_living_draft_packages=SAFE_REMOVE_CANDIDATE_ATLAS_COPY_PRESERVED",
    );
  } else {
    console.log(
      "matilda_living_draft_packages=PRESERVE_OR_RETIRE_PENDING_DEPENDENCY_REVIEW",
    );
  }

  console.log("\n=== CLEANUP CLASSIFICATION ===");

  if (
    activeContext.length === 1 &&
    turns.length === 1 &&
    conversations.length === 1 &&
    iel.length === 1 &&
    drafts.length === 1 &&
    revisionRefs.length === 0 &&
    canonicalRefs.length === 0 &&
    governancePackageRefs.length === 0 &&
    atlasRows.length === 2 &&
    atlasSerialized.includes(ielId) &&
    atlasSerialized.includes(draftId)
  ) {
    console.log(
      "MATILDA_DOGFOOD_CLEANUP_CLASS=BOUNDED_SOURCE_ROW_REMOVAL_APPEARS_SAFE",
    );
    console.log(
      "ATLAS_QA_PRESERVATION_CLASS=INDEPENDENT_PERSISTED_COPY_CONFIRMED",
    );
    console.log(
      "PHYSICAL_DELETE_STILL_REQUIRES_EXPLICIT_AUTHORIZATION=YES",
    );
  } else {
    console.log(
      "MATILDA_DOGFOOD_CLEANUP_CLASS=RETIRE_OR_HIDE_PREFERRED",
    );
    console.log(
      "PHYSICAL_DELETE_STILL_REQUIRES_EXPLICIT_AUTHORIZATION=YES",
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
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=IF_ALL_FIVE_ROWS_CLASSIFY_SAFE_PRESENT_EXPLICIT_CLEANUP_AUTHORIZATION_GATE"
echo "CLEAR_STOPPING_POINT=YES"
