#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
DB="db/main.db"

printf '\n=== AUTHORIZATION BOUNDARY ===\n'
echo "BOUNDED_ATLAS_LIVE_DOGFOOD_AUTHORIZED=YES"
echo "PROJECT_ID=hq"
echo "FRESH_CONVERSATIONS_AUTHORIZED=1"
echo "NORMAL_WORKFLOW_TURNS_AUTHORIZED=1"
echo "PRODUCTION_DATABASE=$DB"
echo "APPROVAL_AUTHORIZED=NO"
echo "DELEGATION_AUTHORIZED=NO"
echo "VALIDATION_AUTHORIZED=NO"
echo "ENVELOPE_AUTHORIZED=NO"
echo "EXECUTION_AUTHORIZED=NO"
echo "SCHEDULING_AUTHORIZED=NO"
echo "ROUTING_AUTHORIZED=NO"
echo "ORCHESTRATION_AUTHORIZED=NO"
echo "SELF_AUTHORIZATION=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "APPROVALS_UI_CHANGE_AUTHORIZED=NO"
echo "PRODUCT_CODE_CHANGE_AUTHORIZED=NO"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

PRE_HEAD="$(git rev-parse HEAD)"
echo "PRE_HEAD=$PRE_HEAD"

printf '\n=== CAPTURE PRE-DOGFOOD DATABASE STATE ===\n'
node --import tsx <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

try {
  const scalar = (sql) => db.prepare(sql).get().count;

  console.log(
    `PRE_CONVERSATIONS=${scalar(`
      SELECT COUNT(*) AS count
      FROM matilda_conversations
      WHERE project_id = 'hq'
    `)}`,
  );

  console.log(
    `PRE_TURNS=${scalar(`
      SELECT COUNT(*) AS count
      FROM matilda_conversation_turns
      WHERE project_id = 'hq'
    `)}`,
  );

  console.log(
    `PRE_IEL=${scalar(`
      SELECT COUNT(*) AS count
      FROM matilda_interpretation_evidence_ledger
      WHERE project_id = 'hq'
    `)}`,
  );

  console.log(
    `PRE_ATLAS=${scalar(`
      SELECT COUNT(*) AS count
      FROM atlas_historical_observations
      WHERE project_id = 'hq'
    `)}`,
  );
} finally {
  db.close();
}
NODE

printf '\n=== CREATE EXACTLY ONE FRESH DOGFOOD CONVERSATION ===\n'
DOGFOOD_CONVERSATION_ID="$(
node --import tsx <<'NODE'
const runtime = require("./db/matilda-conversation-runtime.ts");

const conversation =
  runtime.createMatildaConversation("hq");

process.stdout.write(conversation.conversation_id);
NODE
)"

test -n "$DOGFOOD_CONVERSATION_ID"
echo "DOGFOOD_CONVERSATION_ID=$DOGFOOD_CONVERSATION_ID"

printf '\n=== EXECUTE EXACTLY ONE NORMAL MATILDA WORKFLOW TURN ===\n'
DOGFOOD_CONVERSATION_ID="$DOGFOOD_CONVERSATION_ID" \
node --import tsx <<'NODE'
const {
  runMatildaConversationWorkflow,
} = require("./server/matilda-chat-workflow.ts");

const conversationId =
  process.env.DOGFOOD_CONVERSATION_ID;

if (!conversationId) {
  throw new Error("Missing DOGFOOD_CONVERSATION_ID");
}

const input = {
  project_id: "hq",
  conversation_id: conversationId,
  message:
    "Atlas bounded live-dogfood validation: record this ordinary conversation turn so historical observation persistence and conversation-scoped readback can be verified. Do not approve, delegate, validate, schedule, route, orchestrate, execute, or authorize anything.",
};

const result =
  await runMatildaConversationWorkflow(input);

console.log(
  "DOGFOOD_WORKFLOW_RESULT=" +
    JSON.stringify(result),
);
NODE

printf '\n=== VERIFY EXACT CONVERSATION LINEAGE ===\n'
DOGFOOD_CONVERSATION_ID="$DOGFOOD_CONVERSATION_ID" \
node --import tsx <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

const conversationId =
  process.env.DOGFOOD_CONVERSATION_ID;

try {
  const conversation = db.prepare(`
    SELECT *
    FROM matilda_conversations
    WHERE project_id = 'hq'
      AND conversation_id = ?
  `).get(conversationId);

  const turns = db.prepare(`
    SELECT *
    FROM matilda_conversation_turns
    WHERE project_id = 'hq'
      AND conversation_id = ?
    ORDER BY created_at ASC
  `).all(conversationId);

  const evidence = db.prepare(`
    SELECT *
    FROM matilda_interpretation_evidence_ledger
    WHERE project_id = 'hq'
      AND conversation_id = ?
    ORDER BY created_at ASC
  `).all(conversationId);

  const atlas = db.prepare(`
    SELECT
      project_id,
      conversation_id,
      source_kind,
      source_id,
      source_updated_at,
      authority_status,
      observed_at
    FROM atlas_historical_observations
    WHERE project_id = 'hq'
      AND conversation_id = ?
    ORDER BY observed_at ASC
  `).all(conversationId);

  console.log(
    "DOGFOOD_CONVERSATION=" +
      JSON.stringify(conversation),
  );

  console.log(
    "DOGFOOD_TURNS=" +
      JSON.stringify(turns),
  );

  console.log(
    "DOGFOOD_IEL=" +
      JSON.stringify(evidence),
  );

  console.log(
    "DOGFOOD_ATLAS_HISTORY=" +
      JSON.stringify(atlas),
  );

  if (!conversation) {
    throw new Error(
      "Dogfood conversation was not persisted",
    );
  }

  if (turns.length < 1) {
    throw new Error(
      "Dogfood workflow turn was not persisted",
    );
  }

  if (evidence.length < 1) {
    throw new Error(
      "Dogfood interpretation evidence was not persisted",
    );
  }

  if (atlas.length < 1) {
    throw new Error(
      "Atlas historical observation was not persisted",
    );
  }

  if (
    atlas.some(
      (row) =>
        row.authority_status !== "non_authoritative",
    )
  ) {
    throw new Error(
      "Atlas dogfood unexpectedly promoted authority",
    );
  }
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY CONVERSATION-SCOPED ATLAS READBACK ===\n'
DOGFOOD_CONVERSATION_ID="$DOGFOOD_CONVERSATION_ID" \
node --import tsx <<'NODE'
const {
  readAtlasTypedPreexecutionObservations,
} = require(
  "./server/atlas/atlas-preexecution-observation-aggregator.ts",
);

const conversationId =
  process.env.DOGFOOD_CONVERSATION_ID;

const observations =
  readAtlasTypedPreexecutionObservations(
    "hq",
    conversationId,
  );

console.log(
  "ATLAS_CONVERSATION_SCOPED_READBACK=" +
    JSON.stringify(observations),
);

if (
  !Array.isArray(observations) ||
  observations.length < 1
) {
  throw new Error(
    "Atlas conversation-scoped readback returned no observations",
  );
}

if (
  observations.some(
    (observation) =>
      observation.projectId !== "hq" ||
      observation.conversationId !==
        conversationId,
  )
) {
  throw new Error(
    "Atlas readback escaped authorized conversation scope",
  );
}
NODE

printf '\n=== VERIFY NO PRODUCT OR AUTHORITY-SURFACE CHANGE ===\n'
test "$(git rev-parse HEAD)" = "$PRE_HEAD"
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
echo "BOUNDED_ATLAS_LIVE_DOGFOOD=EXECUTED"
echo "DOGFOOD_CONVERSATION_ID=$DOGFOOD_CONVERSATION_ID"
echo "AUTHORIZED_CONVERSATIONS_CREATED=1"
echo "AUTHORIZED_NORMAL_WORKFLOW_TURNS=1"
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
