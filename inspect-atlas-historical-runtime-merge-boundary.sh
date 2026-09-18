#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="1e05bbf0d"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

printf '\n=== EXACT ROUTE READ / REASON BOUNDARY ===\n'
sed -n '1,125p' server/routes/atlas/preexecution.ts

printf '\n=== EXACT AGGREGATOR READ BOUNDARY ===\n'
sed -n '70,255p' \
  server/atlas/atlas-preexecution-observation-aggregator.ts

printf '\n=== HISTORICAL READ API / DATABASE BINDING ===\n'
grep -n -B25 -A90 \
  'export function readAtlasHistoricalObservations' \
  db/atlas-historical-observation-persistence.ts

printf '\n=== HISTORICAL ADAPTER READ API ===\n'
sed -n '245,290p' \
  server/atlas/atlas-historical-observation-adapter.ts

printf '\n=== LIVE AND HISTORICAL IDENTITY COMPARISON ===\n'
grep -n -A20 -B5 \
  'function stableIdentity' \
  server/atlas/atlas-preexecution-observation-aggregator.ts

grep -n -A18 -B5 \
  'atlasLivingDraftSourceIdentity' \
  db/atlas-historical-observation-persistence.ts

printf '\n=== HISTORICAL RECORD ORDER / FILTER CONTRACT ===\n'
grep -n -E \
  'SELECT|WHERE|ORDER BY|project_id|conversation_id|source_kind|source_identity|observed_at' \
  db/atlas-historical-observation-persistence.ts \
  | head -260

printf '\n=== AGGREGATOR TEST CONTRACT ===\n'
sed -n '1,240p' \
  server/atlas/atlas-preexecution-observation-aggregator.test.ts

printf '\n=== ROUTE TEST CONTRACT ===\n'
sed -n '1,190p' server/routes/atlas/preexecution.test.ts

printf '\n=== CLASSIFICATION TARGET ===\n'
echo "QUESTION=What is the smallest typed runtime merge that exposes immutable historical IEL and Living Draft observations while preserving current live-state semantics and revision-aware identities?"
echo "IEL_DEDUP_CANDIDATE=entryId"
echo "LIVING_DRAFT_HISTORY_IDENTITY=draftPackageId+updatedAt"
echo "LIVING_DRAFT_REVISIONS=MUST_REMAIN_DISTINCT"
echo "ROUTE_MUTATION=PROHIBITED"
echo "LIVE_READER_REPLACEMENT=PROHIBITED"
echo "STRUCTURAL_REASONER_MUTATION=PROHIBITED"
echo "AUTHORITY_CHANGE=PROHIBITED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "CORRIDOR_STATUS=ACTIVE"

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
git diff --cached --name-status

test -z "$(
  git diff --name-only -- \
    server/routes/atlas/preexecution.ts \
    server/atlas/atlas-preexecution-observation-aggregator.ts \
    server/atlas/atlas-preexecution-structural-reasoner.ts \
    server/atlas/atlas-historical-observation-adapter.ts \
    db/atlas-historical-observation-persistence.ts
)"

printf '\n=== STOP ===\n'
echo "NO MUTATION / NO PRODUCT COMMIT / NO PRODUCT PUSH"
