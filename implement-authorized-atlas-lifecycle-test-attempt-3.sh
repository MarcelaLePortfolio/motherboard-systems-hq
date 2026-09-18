#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

printf '\n=== VERIFY AUTHORIZED ATTEMPT 3 BASELINE ===\n'
git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

printf '\n=== PRESERVE AUTHORIZATION BOUNDARY ===\n'
echo "ATTEMPT_3_AUTHORIZED=YES"
echo "AUTHORIZED_PATH_ONLY=$TEST"
echo "PRODUCT_CODE_CHANGE_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "SCHEDULING_AUTHORITY_CHANGE=NO"
echo "ROUTING_AUTHORITY_CHANGE=NO"
echo "ORCHESTRATION_AUTHORITY_CHANGE=NO"
echo "SELF_AUTHORIZATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"

printf '\n=== APPLY ATTEMPT 3 IMPORT-TIMING FIX ===\n'
python3 - <<'PY'
from pathlib import Path

path = Path("server/matilda-chat-workflow.explicit-target.integration.test.ts")
text = path.read_text()

imports = '''import {
  readAtlasHistoricalObservations,
} from "../db/atlas-historical-observation-persistence";
import {
  readAtlasHistoricalTypedObservations,
} from "./atlas/atlas-historical-observation-adapter";
import {
  readAtlasTypedPreexecutionObservations,
} from "./atlas/atlas-preexecution-observation-aggregator";

'''

if text.count(imports) != 1:
    raise SystemExit("FAIL CLOSED: expected exactly one Atlas top-level import block")

text = text.replace(imports, "", 1)

anchor = '''        const workflowRuntime =
          require(
            "./matilda-chat-workflow",
          ) as typeof import(
            "./matilda-chat-workflow"
          );
'''

if text.count(anchor) != 1:
    raise SystemExit("FAIL CLOSED: expected exactly one fixture-local workflow require anchor")

replacement = anchor + '''
        const historicalObservationRuntime =
          require(
            "../db/atlas-historical-observation-persistence",
          ) as typeof import(
            "../db/atlas-historical-observation-persistence"
          );

        const historicalObservationAdapter =
          require(
            "./atlas/atlas-historical-observation-adapter",
          ) as typeof import(
            "./atlas/atlas-historical-observation-adapter"
          );

        const preexecutionObservationAggregator =
          require(
            "./atlas/atlas-preexecution-observation-aggregator",
          ) as typeof import(
            "./atlas/atlas-preexecution-observation-aggregator"
          );

        const {
          readAtlasHistoricalObservations,
        } = historicalObservationRuntime;

        const {
          readAtlasHistoricalTypedObservations,
        } = historicalObservationAdapter;

        const {
          readAtlasTypedPreexecutionObservations,
        } = preexecutionObservationAggregator;
'''

text = text.replace(anchor, replacement, 1)
path.write_text(text)
PY

printf '\n=== VERIFY ATTEMPT 2 IEL INITIALIZATION PRESERVED ===\n'
grep -n -A16 \
  'CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger' \
  "$TEST"

printf '\n=== VERIFY IMPORT TIMING ===\n'
if grep -nE \
  '^import .*atlas|^} from ".*atlas-(historical|preexecution)' \
  "$TEST"; then
  echo "FAIL CLOSED: Atlas reader top-level import remains"
  exit 1
fi

grep -n -A70 \
  'process.env.OLLAMA_BASE_URL' \
  "$TEST" | head -n 90

printf '\n=== VERIFY AUTHORIZED DIFF ONLY ===\n'
git diff --check -- "$TEST"
git diff -- "$TEST"

PRODUCT_DIFF="$(
  git diff --name-only -- \
    server \
    db \
    client |
  grep -v "^${TEST}$" \
  || true
)"

test -z "$PRODUCT_DIFF"

printf '\n=== VERIFY PROTECTED PRODUCT BOUNDARIES ===\n'
PROTECTED_STATUS=0
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts \
  || PROTECTED_STATUS=$?

printf 'PROTECTED_STATUS=%s\n' "$PROTECTED_STATUS"
test "$PROTECTED_STATUS" -eq 0

printf '\n=== TYPECHECK ===\n'
set +e
npx tsc --noEmit
TSC_STATUS=$?
set -e
printf 'TSC_STATUS=%s\n' "$TSC_STATUS"

printf '\n=== AUTHORIZED INTEGRATION TEST ===\n'
set +e
node --import tsx --test "$TEST"
TEST_STATUS=$?
set -e
printf 'TEST_STATUS=%s\n' "$TEST_STATUS"

printf '\n=== ATLAS REGRESSION TESTS ===\n'
set +e
node --import tsx --test \
  db/atlas-historical-observation-persistence.test.ts
PERSISTENCE_STATUS=$?

node --import tsx --test \
  server/atlas/atlas-historical-observation-adapter.test.ts
ADAPTER_STATUS=$?

node --import tsx --test \
  server/atlas/atlas-preexecution-observation-aggregator.test.ts
AGGREGATOR_STATUS=$?

node --import tsx --test \
  server/routes/atlas/preexecution.test.ts
ROUTE_STATUS=$?
set -e

printf 'PERSISTENCE_STATUS=%s\n' "$PERSISTENCE_STATUS"
printf 'ADAPTER_STATUS=%s\n' "$ADAPTER_STATUS"
printf 'AGGREGATOR_STATUS=%s\n' "$AGGREGATOR_STATUS"
printf 'ROUTE_STATUS=%s\n' "$ROUTE_STATUS"

printf '\n=== VERIFY NOTHING STAGED ===\n'
git diff --cached --name-status
test -z "$(git diff --cached --name-only)"

printf '\n=== ATTEMPT 3 CLASSIFICATION ===\n'
if [ "$TSC_STATUS" -eq 0 ] && \
   [ "$TEST_STATUS" -eq 0 ] && \
   [ "$PERSISTENCE_STATUS" -eq 0 ] && \
   [ "$ADAPTER_STATUS" -eq 0 ] && \
   [ "$AGGREGATOR_STATUS" -eq 0 ] && \
   [ "$ROUTE_STATUS" -eq 0 ] && \
   [ "$PROTECTED_STATUS" -eq 0 ]; then
  echo "ATLAS_LIFECYCLE_TEST_ATTEMPT_3=VALIDATED_LOCAL_ONLY"
  echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
  echo "AUTHORIZED_TEST_PATH_ONLY=YES"
  echo "PRODUCT_CODE_CHANGED=NO"
  echo "LIVE_DOGFOOD_EXECUTED=NO"
  echo "PRODUCTION_DATABASE_MUTATED=NO"
  echo "DESTRUCTIVE_CLEANUP=NO"
  echo "AUTHORITY_CHANGE=NO"
  echo "CLEAR_STOPPING_POINT=YES"
  echo "SAFE_TO_STOP_HERE=YES"
  echo "NEXT_GATE=TEST_COMMIT_AND_PUSH_AUTHORIZATION"
else
  echo "ATLAS_LIFECYCLE_TEST_ATTEMPT_3=FAILED_OR_BLOCKED"
  echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=3"
  echo "THREE_FAILED_HYPOTHESIS_LIMIT_REACHED=YES"
  echo "CLEAR_STOPPING_POINT=YES"
  echo "SAFE_TO_STOP_HERE=YES"
  echo "NEXT_ACTION=REVERT_TO_LAST_KNOWN_STABLE_TEST_STATE_AND_REASSESS"
fi

printf '\n=== AUTHORIZED TEST STATUS ===\n'
git status --short -- "$TEST"

printf '\n=== STOP ===\n'
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "NO TEST COMMIT / NO TEST PUSH"
