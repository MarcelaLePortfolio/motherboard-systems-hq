#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
DOGFOOD_CONVERSATION_ID="matilda-conversation-hq-1789754980083-t80g6h"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== REUSE EXISTING AUTHORIZED CONVERSATION ===\n'
echo "DOGFOOD_CONVERSATION_ID=$DOGFOOD_CONVERSATION_ID"
echo "CREATE_NEW_CONVERSATION=NO"
echo "AUTHORIZED_NORMAL_WORKFLOW_TURNS_REMAINING=1"
echo "TOOLING_FAILURE_ONLY=YES"
echo "PRODUCT_HYPOTHESIS_FAILURE=NO"

printf '\n=== VERIFY CONVERSATION EXISTS AND HAS NO TURN ===\n'
DOGFOOD_CONVERSATION_ID="$DOGFOOD_CONVERSATION_ID" \
node --import tsx <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

const conversationId = process.env.DOGFOOD_CONVERSATION_ID;

try {
  const conversation = db.prepare(`
    SELECT conversation_id, project_id, status, created_at
    FROM matilda_conversations
    WHERE project_id = 'hq'
      AND conversation_id = ?
  `).get(conversationId);

  const turns = db.prepare(`
    SELECT COUNT(*) AS count
    FROM matilda_conversation_turns
    WHERE project_id = 'hq'
      AND conversation_id = ?
  `).get(conversationId);

  const evidence = db.prepare(`
    SELECT COUNT(*) AS count
    FROM matilda_interpretation_evidence_ledger
    WHERE project_id = 'hq'
      AND conversation_id = ?
  `).get(conversationId);

  const atlas = db.prepare(`
    SELECT COUNT(*) AS count
    FROM atlas_historical_observations
    WHERE project_id = 'hq'
      AND conversation_id = ?
  `).get(conversationId);

  console.log("DOGFOOD_CONVERSATION=" + JSON.stringify(conversation));
  console.log(`PRE_RETRY_TURNS=${turns.count}`);
  console.log(`PRE_RETRY_IEL=${evidence.count}`);
  console.log(`PRE_RETRY_ATLAS=${atlas.count}`);

  if (!conversation) {
    throw new Error("Authorized dogfood conversation is missing");
  }

  if (turns.count !== 0 || evidence.count !== 0 || atlas.count !== 0) {
    throw new Error(
      "Fail closed: prior attempt produced workflow effects; do not retry blindly",
    );
  }
} finally {
  db.close();
}
NODE

printf '\n=== EXECUTE EXACTLY ONE NORMAL WORKFLOW TURN ===\n'
DOGFOOD_CONVERSATION_ID="$DOGFOOD_CONVERSATION_ID" \
node --import tsx <<'NODE'
const {
  runMatildaConversationWorkflow,
} = require("./server/matilda-chat-workflow.ts");

(async () => {
  const conversationId = process.env.DOGFOOD_CONVERSATION_ID;

  if (!conversationId) {
    throw new Error("Missing DOGFOOD_CONVERSATION_ID");
  }

  const result = await runMatildaConversationWorkflow({
    project_id: "hq",
    conversation_id: conversationId,
    message:
      "Atlas bounded live-dogfood validation: record this ordinary conversation turn so historical observation persistence and conversation-scoped readback can be verified. Do not approve, delegate, validate, schedule, route, orchestrate, execute, or authorize anything.",
  });

  console.log(
    "DOGFOOD_WORKFLOW_RESULT=" +
      JSON.stringify({
        conversation_id: result.conversation_id,
        draft_package_updated: result.draft_package_updated,
        canonical_package_created: result.canonical_package_created,
        delegation_authorized: result.delegation_authorized,
        validation_authorized: result.validation_authorized,
        envelope_authorized: result.envelope_authorized,
        execution_authorized: result.execution_authorized,
      }),
  );

  if (
    result.canonical_package_created !== false ||
    result.delegation_authorized !== false ||
    result.validation_authorized !== false ||
    result.envelope_authorized !== false ||
    result.execution_authorized !== false
  ) {
    throw new Error("Fail closed: workflow promoted authority");
  }
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
NODE

printf '\n=== VERIFY PERSISTENCE AND READBACK ===\n'
DOGFOOD_CONVERSATION_ID="$DOGFOOD_CONVERSATION_ID" \
node --import tsx <<'NODE'
const Database = require("better-sqlite3");
const {
  readAtlasTypedPreexecutionObservations,
} = require(
  "./server/atlas/atlas-preexecution-observation-aggregator.ts",
);

const conversationId = process.env.DOGFOOD_CONVERSATION_ID;

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

try {
  const turns = db.prepare(`
    SELECT COUNT(*) AS count
    FROM matilda_conversation_turns
    WHERE project_id = 'hq'
      AND conversation_id = ?
  `).get(conversationId);

  const evidence = db.prepare(`
    SELECT COUNT(*) AS count
    FROM matilda_interpretation_evidence_ledger
    WHERE project_id = 'hq'
      AND conversation_id = ?
  `).get(conversationId);

  const atlasRows = db.prepare(`
    SELECT
      source_kind,
      authority_status,
      observed_at
    FROM atlas_historical_observations
    WHERE project_id = 'hq'
      AND conversation_id = ?
    ORDER BY observed_at ASC
  `).all(conversationId);

  console.log(`POST_RETRY_TURNS=${turns.count}`);
  console.log(`POST_RETRY_IEL=${evidence.count}`);
  console.log(
    "POST_RETRY_ATLAS_ROWS=" +
      JSON.stringify(atlasRows),
  );

  if (turns.count !== 1) {
    throw new Error(
      `Expected exactly one dogfood turn; found ${turns.count}`,
    );
  }

  if (evidence.count < 1) {
    throw new Error("No IEL evidence persisted");
  }

  if (atlasRows.length < 1) {
    throw new Error("No Atlas historical observation persisted");
  }

  const observations =
    readAtlasTypedPreexecutionObservations({
      projectId: "hq",
      conversationId,
      databasePath: "db/main.db",
    });

  console.log(
    "ATLAS_SCOPED_READBACK=" +
      JSON.stringify(observations),
  );

  if (observations.length < 1) {
    throw new Error("Atlas scoped readback returned no observations");
  }

  if (
    observations.some(
      (observation) =>
        observation.projectId !== "hq" ||
        observation.conversationId !== conversationId,
    )
  ) {
    throw new Error("Atlas readback escaped dogfood conversation scope");
  }
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY NO PRODUCT / UI MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-living-draft-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts \
  client/src/atlas/atlasPreexecutionApi.ts \
  client/src/atlas/AtlasPreexecutionPresentation.tsx \
  client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "BOUNDED_ATLAS_LIVE_DOGFOOD=PASS"
echo "DOGFOOD_CONVERSATION_ID=$DOGFOOD_CONVERSATION_ID"
echo "NEW_CONVERSATION_CREATED_ON_RETRY=NO"
echo "NORMAL_WORKFLOW_TURNS_EXECUTED_TOTAL=1"
echo "ATLAS_HISTORICAL_PERSISTENCE=PROVEN"
echo "ATLAS_CONVERSATION_SCOPED_READBACK=PROVEN"
echo "ATLAS_CARD_DATA_PATH=POPULATED_FOR_DOGFOOD_CONVERSATION"
echo "AUTHORITY_PROMOTION=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "APPROVALS_UI_CHANGED=NO"
echo "DESTRUCTIVE_CLEANUP=NO"
echo "BROADER_ATLAS_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
echo "NEXT_ACTION=VERIFY_ATLAS_CARD_PRESENTATION_AND_CLASSIFY_CORRIDOR_CLOSURE"
