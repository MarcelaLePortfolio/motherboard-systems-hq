#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"

printf '\n=== VERIFY CURRENT CONVERGED BASELINE ===\n'
git fetch origin "$BRANCH"

printf 'LOCAL_HEAD='
git rev-parse --short=9 HEAD
printf 'REMOTE_HEAD='
git rev-parse --short=9 "origin/$BRANCH"
printf 'RELATIONSHIP='
git rev-list --left-right --count "HEAD...origin/$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

printf '\n=== EXISTING EXPLICIT-TARGET WORKFLOW INVOCATIONS ===\n'
sed -n '390,525p' \
  server/matilda-chat-workflow.explicit-target.integration.test.ts

printf '\n=== EXISTING TEST DATABASE ISOLATION / CLEANUP ===\n'
grep -n -B20 -A45 \
  'temporaryRoot\|process.chdir\|rmSync\|closeServer' \
  server/matilda-chat-workflow.explicit-target.integration.test.ts \
  | tail -240

printf '\n=== WORKFLOW DATABASE PATH AUTHORITY ===\n'
git grep -n -E \
  'main\.db|MATILDA.*DB|databasePath|dbPath|process\.cwd\(\)' \
  -- \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-chat-draft-integration.ts \
  db/atlas-historical-observation-persistence.ts \
  server/matilda-chat-workflow.ts \
  | head -320 || true

printf '\n=== HISTORICAL WRITER DATABASE TARGET ===\n'
sed -n '1,310p' \
  db/atlas-historical-observation-persistence.ts

printf '\n=== EXISTING ISOLATED WORKFLOW TEST ATLAS ASSERTIONS ===\n'
git grep -n -E \
  'atlas_historical_observations|readAtlasHistorical|persistAtlasHistorical|historical.*observation' \
  -- server/matilda-chat-workflow.explicit-target.integration.test.ts \
  || true

printf '\n=== CURRENT PRODUCTION HISTORICAL COUNT ===\n'
sqlite3 db/main.db <<'SQL'
SELECT COUNT(*) AS historical_rows
FROM atlas_historical_observations;
SQL

printf '\n=== BOUNDED VALIDATION CLASSIFICATION ===\n'
echo "EXISTING_SAFE_WORKFLOW_HARNESS=server/matilda-chat-workflow.explicit-target.integration.test.ts"
echo "HARNESS_USES_TEMPORARY_DATABASE=VERIFY_FROM_OUTPUT_ABOVE"
echo "HARNESS_USES_LOCAL_OLLAMA_STUB=YES"
echo "DIRECT_WORKFLOW_INVOCATION=CONFIRMED"
echo "PRODUCTION_HISTORICAL_ROWS=0"
echo "PRODUCT_CODE_CHANGE_REQUIRED=UNDETERMINED"
echo "PREFERRED_NEXT_STEP=EXTEND_OR_REUSE_ISOLATED_EXISTING_WORKFLOW_HARNESS_TO_ASSERT_ATLAS_HISTORICAL_PERSISTENCE_AND_TYPED_READBACK"
echo "PRODUCTION_DOGFOOD_MUTATION=NOT_AUTHORIZED"
echo "DESTRUCTIVE_CLEANUP=NOT_AUTHORIZED"
echo "PRODUCT_IMPLEMENTATION=NOT_AUTHORIZED"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "NEXT_GATE=CLASSIFY_TEST_ONLY_VALIDATION_VERSUS_LIVE_DOGFOOD_REQUIREMENT"

printf '\n=== VERIFY NO PRODUCT EFFECT ===\n'
test -z "$(git diff --cached --name-only)"
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts

echo "NO PRODUCT MUTATION / NO DOGFOOD EXECUTION / NO CLEANUP"
