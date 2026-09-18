#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="956cac3d3"
TARGET="db/atlas-historical-observation-persistence.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -f "$TARGET"
test -z "$(git diff --cached --name-only)"

PRE_HEAD="$(git rev-parse HEAD)"

printf '\n=== ESTABLISHED PRESERVATION BOUNDARY ===\n'
echo "DOGFOOD_TOTAL_MATCHING_ROWS=7"
echo "ATLAS_PERSISTED_QA_ROWS=2"
echo "NON_ATLAS_MATILDA_MATCHING_ROWS=5"
echo "ATLAS_QA_EVIDENCE_MUST_BE_PRESERVED=YES"
echo "CLEANUP_EXECUTED=NO"

printf '\n=== PREVIOUS FAILURE CLASS ===\n'
echo "FAILURE_CLASS=INCORRECT_READBACK_EXPORT_NAME"
echo "DATABASE_FAILURE=NO"
echo "ATLAS_PERSISTENCE_FAILURE=NO"
echo "PRODUCT_HYPOTHESIS_FAILURE=NO"

printf '\n=== ACTUAL MODULE EXPORTS ===\n'
grep -nE '^export ' "$TARGET" || true

printf '\n=== READBACK CANDIDATES ===\n'
grep -nE \
  'read|list|load|find|select|historical|observation|conversationId|projectId' \
  "$TARGET" || true

printf '\n=== ATLAS QUERY IMPLEMENTATION ===\n'
grep -nE \
  'SELECT|FROM atlas_historical_observations|WHERE|project_id|conversation_id' \
  "$TARGET" || true

printf '\n=== PRESERVE EXACT ATLAS DOGFOOD ROWS ===\n'
node <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", { readonly: true });

const conversationId =
  "matilda-conversation-hq-1789754980083-t80g6h";

const rows = db.prepare(`
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
  WHERE project_id = ?
    AND conversation_id = ?
  ORDER BY observation_id
`).all("hq", conversationId);

if (rows.length !== 2) {
  throw new Error(
    `Expected exactly 2 preserved Atlas QA rows, received ${rows.length}`,
  );
}

console.log(`ATLAS_PRESERVED_ROW_COUNT=${rows.length}`);

for (const row of rows) {
  console.log(
    `PRESERVE_ATLAS_OBSERVATION=${JSON.stringify(row)}`,
  );
}

console.log(
  "ATLAS_HISTORICAL_DOGFOOD_CLASSIFICATION=PRESERVE_QA_EVIDENCE",
);
NODE

printf '\n=== VERIFY INVESTIGATION READ ONLY ===\n'
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
echo "ATLAS_QA_ROWS_CLASSIFIED=PRESERVE"
echo "ATLAS_QA_EVIDENCE_DELETED=NO"
echo "MATILDA_DOGFOOD_CLEANUP_EXECUTED=NO"
echo "DATABASE_MUTATED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=CLASSIFY_FIVE_NON_ATLAS_MATILDA_ROWS_WITH_ACTUAL_READBACK_API_KNOWN"
echo "CLEAR_STOPPING_POINT=YES"
