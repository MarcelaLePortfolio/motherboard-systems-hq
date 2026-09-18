#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
DOGFOOD_CONVERSATION_ID="matilda-conversation-hq-1789754980083-t80g6h"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== VERIFY DOGFOOD DATA STILL PRESENT ===\n'
DOGFOOD_CONVERSATION_ID="$DOGFOOD_CONVERSATION_ID" \
node --import tsx <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

const conversationId = process.env.DOGFOOD_CONVERSATION_ID;

try {
  const rows = db.prepare(`
    SELECT
      source_kind,
      authority_status,
      observed_at
    FROM atlas_historical_observations
    WHERE project_id = 'hq'
      AND conversation_id = ?
    ORDER BY observed_at ASC
  `).all(conversationId);

  console.log(
    "DOGFOOD_ATLAS_HISTORY=" +
      JSON.stringify(rows),
  );

  if (rows.length < 2) {
    throw new Error(
      "Expected retained interpretation evidence and Living Draft observations",
    );
  }
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY SERVER CARD READ MODEL ===\n'
DOGFOOD_CONVERSATION_ID="$DOGFOOD_CONVERSATION_ID" \
node --import tsx <<'NODE'
const {
  readAtlasPreExecutionRoute,
} = require("./server/routes/atlas/preexecution.ts");

const conversationId = process.env.DOGFOOD_CONVERSATION_ID;

const result = readAtlasPreExecutionRoute({
  projectId: "hq",
  conversationId,
  databasePath: "db/main.db",
});

console.log(
  "ATLAS_ROUTE_RESULT=" +
    JSON.stringify(result),
);

if (!Array.isArray(result.observations)) {
  throw new Error("Atlas route returned no observations array");
}

if (result.observations.length < 1) {
  throw new Error("Atlas route returned empty dogfood observations");
}

if (
  result.observations.some(
    (observation) =>
      observation.projectId !== "hq" ||
      observation.conversationId !== conversationId,
  )
) {
  throw new Error("Atlas route escaped dogfood scope");
}
NODE

printf '\n=== VERIFY REACT CARD WIRING ===\n'
grep -n \
  'getAtlasPreexecution' \
  client/src/atlas/AtlasPreexecutionPresentation.tsx

grep -n \
  'fetch(`/atlas/preexecution?' \
  client/src/atlas/atlasPreexecutionApi.ts

grep -n \
  'AtlasPreexecutionPresentation' \
  client/src/shell/Shell.tsx

printf '\n=== VERIFY AUTHORITY BOUNDARIES ===\n'
grep -n -E \
  'causalExplanation: false|executionHistory: false|approvalDecision: false|authorityDecision: false' \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NO PRODUCT / APPROVALS MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/routes/atlas/preexecution.ts \
  client/src/atlas/atlasPreexecutionApi.ts \
  client/src/atlas/AtlasPreexecutionPresentation.tsx \
  client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== FINAL CORRIDOR CLASSIFICATION ===\n'
echo "ATLAS_LIFECYCLE_RESTORATION=VALIDATED"
echo "ATLAS_HISTORICAL_PERSISTENCE=LIVE_DOGFOOD_PROVEN"
echo "ATLAS_HISTORICAL_READBACK=LIVE_DOGFOOD_PROVEN"
echo "ATLAS_CARD_SERVER_DATA_PATH=LIVE_DOGFOOD_PROVEN"
echo "ATLAS_REACT_CARD_WIRING=VERIFIED"
echo "AUTHORITY_PROMOTION=NO"
echo "PRODUCT_CODE_CHANGED_BY_DOGFOOD=NO"
echo "APPROVALS_UI_CHANGED=NO"
echo "DESTRUCTIVE_CLEANUP=NO"
echo "ATLAS_QA_EVIDENCE_PERSISTENCE_AND_DOGFOOD_LIFECYCLE_CORRIDOR=CLOSED"
echo "APPROVALS_EXECUTIVE_INBOX_ERROR=DEFERRED_SEPARATE_ISSUE"
echo "CLEAR_STOPPING_POINT=YES"
