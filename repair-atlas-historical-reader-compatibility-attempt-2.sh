#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="2268b5d66"

PERSISTENCE="db/atlas-historical-observation-persistence.ts"
ADAPTER="server/atlas/atlas-historical-observation-adapter.ts"
AGGREGATOR="server/atlas/atlas-preexecution-observation-aggregator.ts"
ROUTE="server/routes/atlas/preexecution.ts"
REASONER="server/atlas/atlas-preexecution-structural-reasoner.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

python3 - <<'PY'
from pathlib import Path

path = Path("db/atlas-historical-observation-persistence.ts")
text = path.read_text()

old = '''export function readAtlasHistoricalObservations(
  projectId: string,
  databasePath = "db/main.db",
  db?: any,
): AtlasHistoricalObservationRecord[] {
  const sqlite = db ?? new Database(databasePath);
  const ownsConnection = db === undefined;
'''

new = '''export function readAtlasHistoricalObservations(
  projectId: string,
  databasePathOrDb: string | any = "db/main.db",
): AtlasHistoricalObservationRecord[] {
  const suppliedDatabase =
    typeof databasePathOrDb === "string"
      ? null
      : databasePathOrDb;

  const sqlite =
    suppliedDatabase ??
    new Database(databasePathOrDb as string);

  const ownsConnection = suppliedDatabase === null;
'''

if text.count(old) != 1:
    raise SystemExit(
        f"FAIL CLOSED: compatibility seam mismatch; found {text.count(old)}"
    )

path.write_text(text.replace(old, new, 1))
PY

printf '\n=== DIFF CHECK ===\n'
git diff --check -- \
  "$PERSISTENCE" \
  "$ADAPTER" \
  "$AGGREGATOR"

printf '\n=== TYPECHECK ===\n'
set +e
npx tsc --noEmit
TSC_STATUS=$?
set -e
printf 'TSC_STATUS=%s\n' "$TSC_STATUS"

printf '\n=== HISTORICAL PERSISTENCE TESTS ===\n'
set +e
npx tsx --test db/atlas-historical-observation-persistence.test.ts
PERSISTENCE_STATUS=$?
set -e
printf 'PERSISTENCE_STATUS=%s\n' "$PERSISTENCE_STATUS"

printf '\n=== HISTORICAL ADAPTER TESTS ===\n'
set +e
npx tsx --test server/atlas/atlas-historical-observation-adapter.test.ts
ADAPTER_STATUS=$?
set -e
printf 'ADAPTER_STATUS=%s\n' "$ADAPTER_STATUS"

printf '\n=== AGGREGATOR TESTS ===\n'
set +e
npx tsx --test server/atlas/atlas-preexecution-observation-aggregator.test.ts
AGGREGATOR_STATUS=$?
set -e
printf 'AGGREGATOR_STATUS=%s\n' "$AGGREGATOR_STATUS"

printf '\n=== ROUTE TESTS ===\n'
set +e
npx tsx --test server/routes/atlas/preexecution.test.ts
ROUTE_STATUS=$?
set -e
printf 'ROUTE_STATUS=%s\n' "$ROUTE_STATUS"

printf '\n=== PROTECTED BOUNDARIES ===\n'
PROTECTED_STATUS=0
git diff --exit-code -- "$ROUTE" "$REASONER" || PROTECTED_STATUS=$?
printf 'PROTECTED_STATUS=%s\n' "$PROTECTED_STATUS"

printf '\n=== ATTEMPT 2 CLASSIFICATION ===\n'
if [ "$TSC_STATUS" -eq 0 ] && \
   [ "$PERSISTENCE_STATUS" -eq 0 ] && \
   [ "$ADAPTER_STATUS" -eq 0 ] && \
   [ "$AGGREGATOR_STATUS" -eq 0 ] && \
   [ "$ROUTE_STATUS" -eq 0 ] && \
   [ "$PROTECTED_STATUS" -eq 0 ]; then
  echo "ATLAS_HISTORICAL_RUNTIME_MERGE_ATTEMPT_2=VALIDATED_LOCAL_ONLY"
  echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
  echo "CLEAR_STOPPING_POINT=YES"
  echo "SAFE_TO_STOP_HERE=YES"
  echo "NEXT_GATE=PRODUCT_COMMIT_AND_PUSH_AUTHORIZATION"
else
  echo "ATLAS_HISTORICAL_RUNTIME_MERGE_ATTEMPT_2=FAILED_OR_BLOCKED"
  echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
  echo "CLEAR_STOPPING_POINT=YES"
  echo "SAFE_TO_STOP_HERE=YES"
  echo "NEXT_ACTION=DIAGNOSE_ATTEMPT_2_ONLY"
fi

printf '\n=== PRODUCT STATUS ===\n'
git status --short -- \
  "$PERSISTENCE" \
  "$ADAPTER" \
  "$AGGREGATOR"

printf '\n=== STOP — NO PRODUCT COMMIT / NO PRODUCT PUSH ===\n'
