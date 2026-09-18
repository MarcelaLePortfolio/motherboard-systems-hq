#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== BASELINE ===\n'
echo "HEAD=$(git rev-parse HEAD)"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "APPROVALS_FIX_AUTHORIZED=NO"

printf '\n=== EXISTING DOGFOOD HELPER ===\n'
if [ -f inspect-atlas-safe-dogfood-validation-seam.sh ]; then
  cat inspect-atlas-safe-dogfood-validation-seam.sh
else
  echo "DOGFOOD_HELPER_NOT_FOUND"
fi

printf '\n=== ATLAS UI COMPONENTS / CARD ===\n'
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E 'Atlas|atlas/preexecution|atlas_preexecution|preexecution' \
  client/src \
  | head -n 320 || true

printf '\n=== ATLAS HTTP READ PATH ===\n'
grep -n -A120 -B30 \
  'atlas/preexecution' \
  server/routes/atlas/preexecution.ts \
  server/index.ts \
  2>/dev/null || true

printf '\n=== ATLAS READ PIPELINE ===\n'
grep -n -A100 -B25 \
  'readAtlasHistoricalTypedObservations\|readAtlasTypedPreexecutionObservations' \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  2>/dev/null || true

printf '\n=== WORKFLOW WRITE SEAMS ===\n'
grep -n -A55 -B30 \
  'persistAtlasHistoricalObservation' \
  server/matilda-chat-workflow.ts \
  | head -n 260 || true

printf '\n=== EXECUTIVE INBOX / APPROVALS WIRING — INSPECTION ONLY ===\n'
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E 'Unable to load Executive Inbox|Executive Inbox|executive.inbox|executive-inbox' \
  client/src server \
  | head -n 260 || true

printf '\n=== PRODUCTION ATLAS STATE — READ ONLY ===\n'
node --import tsx <<'NODE'
const Database = require("better-sqlite3");

const db = new Database("db/main.db", {
  readonly: true,
  fileMustExist: true,
});

try {
  const table = db.prepare(`
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
      AND name = 'atlas_historical_observations'
    LIMIT 1
  `).get();

  console.log(
    `ATLAS_HISTORICAL_TABLE_PRESENT=${table ? "YES" : "NO"}`,
  );

  if (table) {
    const result = db.prepare(`
      SELECT COUNT(*) AS count
      FROM atlas_historical_observations
    `).get();

    console.log(
      `ATLAS_HISTORICAL_OBSERVATION_COUNT=${result.count}`,
    );
  }
} finally {
  db.close();
}
NODE

printf '\n=== VERIFY NO MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== CLASSIFICATION ===\n'
echo "INSPECTION_ONLY=YES"
echo "LIVE_DOGFOOD_EXECUTED=NO"
echo "PRODUCTION_DATABASE_MUTATED=NO"
echo "APPROVALS_UI_MUTATED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "BROADER_ATLAS_CORRIDOR_STATUS=ACTIVE"
echo "NEXT_ACTION=PROVE_BOUNDED_DOGFOOD_WRITE_AND_ATLAS_CARD_READ_SEAM"
echo "CLEAR_STOPPING_POINT=YES"
