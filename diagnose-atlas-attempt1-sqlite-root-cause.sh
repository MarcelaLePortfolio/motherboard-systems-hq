#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== CURRENT BASELINE ===\n'
printf 'LOCAL_HEAD='
git rev-parse --short=9 HEAD
printf 'REMOTE_HEAD='
git rev-parse --short=9 "origin/$BRANCH"

printf '\n=== AUTHORIZED TEST CALL SITES ===\n'
grep -n -B20 -A100 -E \
  'readAtlasHistoricalObservations|readAtlasHistoricalTypedObservations|readAtlasTypedPreexecutionObservations' \
  "$TEST"

printf '\n=== EXACT READER SIGNATURES ===\n'
grep -n -B15 -A100 -E \
  '^export function readAtlasHistoricalObservations|^export function readAtlasHistoricalTypedObservations|^export function readAtlasTypedPreexecutionObservations' \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts

printf '\n=== AGGREGATOR LIVE READ DEPENDENCIES ===\n'
sed -n '1,340p' \
  server/atlas/atlas-preexecution-observation-aggregator.ts

printf '\n=== LIVE READ MODEL SQL ===\n'
sed -n '1,360p' \
  server/atlas/atlas-preexecution-read-model.ts

printf '\n=== TEST FIXTURE SCHEMA ===\n'
grep -n -B5 -A30 -E \
  'CREATE TABLE|CREATE INDEX' \
  "$TEST"

printf '\n=== COMPARE REQUIRED TABLES TO FIXTURE TABLES ===\n'
REQUIRED_TABLES="$(
  {
    grep -h -oE 'FROM[[:space:]]+[A-Za-z0-9_]+' \
      server/atlas/atlas-preexecution-read-model.ts \
      server/atlas/atlas-preexecution-observation-aggregator.ts \
      db/atlas-historical-observation-persistence.ts || true
    grep -h -oE 'JOIN[[:space:]]+[A-Za-z0-9_]+' \
      server/atlas/atlas-preexecution-read-model.ts \
      server/atlas/atlas-preexecution-observation-aggregator.ts \
      db/atlas-historical-observation-persistence.ts || true
  } |
  awk '{print $2}' |
  sort -u
)"

FIXTURE_TABLES="$(
  grep -oE 'CREATE TABLE( IF NOT EXISTS)?[[:space:]]+[A-Za-z0-9_]+' "$TEST" |
  awk '{print $NF}' |
  sort -u
)"

printf '%s\n' "$REQUIRED_TABLES" > /tmp/atlas-required-tables.txt
printf '%s\n' "$FIXTURE_TABLES" > /tmp/atlas-fixture-tables.txt

printf '%s\n' '--- REQUIRED ---'
cat /tmp/atlas-required-tables.txt

printf '%s\n' '--- FIXTURE ---'
cat /tmp/atlas-fixture-tables.txt

printf '%s\n' '--- REQUIRED BUT NOT EXPLICITLY CREATED BY TEST ---'
comm -23 \
  /tmp/atlas-required-tables.txt \
  /tmp/atlas-fixture-tables.txt || true

printf '\n=== REPRODUCE FAILURE ONCE ===\n'
set +e
npx tsx --test "$TEST"
TEST_STATUS=$?
set -e
printf 'TEST_STATUS=%s\n' "$TEST_STATUS"

printf '\n=== VERIFY ATTEMPT 1 REMAINS CONTAINED ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

test -z "$(git diff --cached --name-only)"

printf '\n=== DIAGNOSTIC CLASSIFICATION ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_1_TEST_STATUS=$TEST_STATUS"
echo "ATTEMPT_2_EXECUTED=NO"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "NEXT_GATE=CLASSIFY_EXACT_FIXTURE_SCHEMA_OR_DATABASE_BINDING_GAP"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"

printf '\n=== STOP ===\n'
echo "NO ATTEMPT 2 MUTATION / NO TEST COMMIT / NO TEST PUSH"
