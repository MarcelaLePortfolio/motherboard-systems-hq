#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="$(git rev-parse --short=9 HEAD)"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

printf '\n=== EXACT ACTIVE READER IMPLEMENTATION ===\n'
grep -n -A75 -B15 \
  'export function readAtlasTypedPreexecutionObservations' \
  server/atlas/atlas-preexecution-observation-aggregator.ts

printf '\n=== HISTORICAL ADAPTER COMPLETE READ BOUNDARY ===\n'
grep -n -A25 -B10 \
  'export function readAtlasHistoricalTypedObservations' \
  server/atlas/atlas-historical-observation-adapter.ts

printf '\n=== DATABASE-PATH READER CONVENTIONS ===\n'
git grep -n -E \
  'databasePath.*db/main.db|new Database\(databasePath\)|databasePath \?\?' \
  -- server/atlas db \
  | head -320

printf '\n=== OPTIONAL DATABASE CONNECTION CONVENTIONS ===\n'
git grep -n -E \
  'db\?: any|ownsConnection|new Database\("db/main.db"\)' \
  -- db server/atlas \
  | head -320

printf '\n=== AGGREGATOR TEST FILE COMPLETE ===\n'
sed -n '1,320p' \
  server/atlas/atlas-preexecution-observation-aggregator.test.ts

printf '\n=== HISTORICAL ADAPTER TEST FILE COMPLETE ===\n'
sed -n '1,260p' \
  server/atlas/atlas-historical-observation-adapter.test.ts

printf '\n=== TEST DATABASE FIXTURE CONVENTIONS ===\n'
git grep -n -E \
  'Database\(":memory:"\)|mkdtemp|tmpdir|databasePath:|unlinkSync|rmSync' \
  -- 'server/atlas/*.test.ts' 'server/routes/atlas/*.test.ts' 'db/*.test.ts' \
  | head -420

printf '\n=== REQUIRED IMPLEMENTATION SHAPE ===\n'
echo "PRIMARY_MUTATION_CANDIDATE=server/atlas/atlas-preexecution-observation-aggregator.ts"
echo "PRIMARY_TEST_CANDIDATE=server/atlas/atlas-preexecution-observation-aggregator.test.ts"
echo "HISTORICAL_ADAPTER_MUTATION=ONLY_IF_DATABASE_PATH_PROPAGATION_REQUIRES_IT"
echo "PERSISTENCE_MUTATION=ONLY_IF_EXISTING_CONNECTION_CONTRACT_CANNOT_BE_REUSED"
echo "ROUTE_MUTATION=NO"
echo "STRUCTURAL_REASONER_MUTATION=NO"
echo "LIVE_READER_REPLACEMENT=NO"
echo "IEL_DUPLICATE_SUPPRESSION=entryId"
echo "LIVING_DRAFT_REVISION_PRESERVATION=draftPackageId+updatedAt"
echo "CONVERSATION_SCOPE=REQUIRED"
echo "DETERMINISTIC_SORT=REQUIRED"
echo "AUTHORITY_CHANGE=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"

printf '\n=== VERIFY PRODUCT FILES UNCHANGED ===\n'
test -z "$(
  git diff --name-only -- \
    server/atlas/atlas-preexecution-observation-aggregator.ts \
    server/atlas/atlas-preexecution-observation-aggregator.test.ts \
    server/atlas/atlas-historical-observation-adapter.ts \
    db/atlas-historical-observation-persistence.ts \
    server/routes/atlas/preexecution.ts \
    server/atlas/atlas-preexecution-structural-reasoner.ts
)"

test -z "$(git diff --cached --name-only)"

printf '\n=== CLASSIFICATION ===\n'
echo "FINAL_IMPLEMENTATION_SEAM_INSPECTION=COMPLETE"
echo "NEXT_GATE=BOUNDED_HISTORICAL_RUNTIME_MERGE_IMPLEMENTATION_AUTHORIZATION"
echo "CORRIDOR_STATUS=ACTIVE"
echo "NO PRODUCT MUTATION / NO PRODUCT COMMIT / NO PRODUCT PUSH"
