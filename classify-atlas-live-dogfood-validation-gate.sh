#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
EXPECTED_TEST_COMMIT="4b4eb3048580c294bcd640f9731ecb80ad5d53f8"

git fetch origin "$BRANCH"

printf '\n=== VERIFY BRANCH ===\n'
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse "origin/$BRANCH")"

printf 'LOCAL_HEAD=%s\n' "$LOCAL_HEAD"
printf 'REMOTE_HEAD=%s\n' "$REMOTE_HEAD"

test "$LOCAL_HEAD" = "$REMOTE_HEAD"

printf '\n=== VERIFY LIFECYCLE RESTORATION ANCESTRY ===\n'
git merge-base --is-ancestor "$EXPECTED_TEST_COMMIT" HEAD
echo "ATLAS_LIFECYCLE_TEST_COMMIT_PRESENT=YES"

printf '\n=== INSPECT LIVE DOGFOOD SEAMS ===\n'
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'atlas_historical_observations|persistAtlasHistoricalObservation|readAtlasHistoricalObservations|preexecution' \
  server db scripts \
  | head -n 240 || true

printf '\n=== INSPECT EXISTING DOGFOOD HELPERS ===\n'
for candidate in \
  inspect-atlas-safe-dogfood-validation-seam.sh \
  capture-atlas-lifecycle-validation-result.sh \
  db/main.db.pre-dogfood-cleanup-*.bak
do
  find . -maxdepth 3 -name "$candidate" -print
done

printf '\n=== CURRENT PRODUCTION ATLAS TABLE STATE — READ ONLY ===\n'
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
    const count = db.prepare(`
      SELECT COUNT(*) AS count
      FROM atlas_historical_observations
    `).get();

    console.log(
      `ATLAS_HISTORICAL_OBSERVATION_COUNT=${count.count}`,
    );

    const rows = db.prepare(`
      SELECT
        project_id,
        conversation_id,
        source_kind,
        authority_status,
        observed_at
      FROM atlas_historical_observations
      ORDER BY observed_at DESC
      LIMIT 10
    `).all();

    console.log(
      "ATLAS_RECENT_OBSERVATIONS=" +
        JSON.stringify(rows),
    );
  }
} finally {
  db.close();
}
NODE

printf '\n=== CLASSIFICATION ===\n'
echo "LIFECYCLE_RESTORATION=LANDED_AND_PUSHED"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "DOGFOOD_CLASSIFICATION_MODE=READ_ONLY"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
echo "NEXT_GATE=AUTHORIZE_BOUNDED_LIVE_DOGFOOD_ONLY_AFTER_SAFE_SEAM_IS_PROVEN"
