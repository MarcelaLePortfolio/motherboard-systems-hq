#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="ac516e8fb"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

printf '\n=== ACTIVE ROUTE CONTRACT ===\n'
sed -n '1,130p' server/routes/atlas/preexecution.ts

printf '\n=== ACTIVE TYPED READ CONTRACT ===\n'
sed -n '1,280p' server/atlas/atlas-preexecution-observation-aggregator.ts

printf '\n=== HISTORICAL ADAPTER CONTRACT ===\n'
sed -n '1,330p' server/atlas/atlas-historical-observation-adapter.ts

printf '\n=== STRUCTURAL REASONER IDENTITY SEMANTICS ===\n'
sed -n '1,220p' server/atlas/atlas-preexecution-structural-reasoner.ts

printf '\n=== CURRENT PRESENTATION CONTRACT ===\n'
sed -n '1,260p' client/src/atlas/AtlasPreexecutionPresentation.tsx 2>/dev/null || true

printf '\n=== ROUTE TESTS ===\n'
find server -type f -name '*atlas*preexecution*test*' -print | sort

printf '\n=== SEARCH CURRENT ROUTE RESPONSE EXPECTATIONS ===\n'
git grep -n -E \
  'atlas/preexecution|readAtlasTypedPreexecutionObservations|observations|lineageSequences' \
  -- server/atlas server/routes client \
  | head -420

printf '\n=== SEARCH STABLE IDENTITIES AVAILABLE FOR DEDUP ===\n'
git grep -n -E \
  'sourceIdentity|entryId|draftPackageId|updatedAt|stableIdentity|observationIdentity' \
  -- server/atlas db/atlas-historical-observation-persistence.ts \
  | head -420

printf '\n=== VERIFY HISTORICAL CONSUMER ABSENCE ===\n'
git grep -n \
  'readAtlasHistoricalTypedObservations' \
  -- server client db \
  ':!server/atlas/atlas-historical-observation-adapter.ts' \
  ':!server/atlas/atlas-historical-observation-adapter.test.ts' \
  || true

printf '\n=== VERIFY NO EFFECT ===\n'
git diff --cached --name-status
git status --short

printf '\n=== CLASSIFICATION TARGET ===\n'
echo "QUESTION=What is the smallest read-only integration that exposes historical IEL/Living Draft observations while preserving live-state semantics and preventing duplicate live-plus-history records?"
echo "ROUTE_MUTATION=PROHIBITED"
echo "AUTHORITY_CHANGE=PROHIBITED"
echo "LIVE_READER_REPLACEMENT=NOT_ASSUMED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "CORRIDOR_STATUS=ACTIVE"
echo "NO MUTATION / NO COMMIT / NO PUSH"
