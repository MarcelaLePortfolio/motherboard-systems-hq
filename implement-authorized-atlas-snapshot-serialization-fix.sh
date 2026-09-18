#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
WORKFLOW="server/matilda-chat-workflow.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== AUTHORIZATION BOUNDARY ===\n'
echo "SNAPSHOT_SERIALIZATION_FIX_AUTHORIZED=YES"
echo "AUTHORIZED_PRODUCT_PATH=$WORKFLOW"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "PRODUCT_COMMIT_AUTHORIZED=NO"
echo "PRODUCT_PUSH_AUTHORIZED=NO"

printf '\n=== APPLY NARROW SERIALIZATION FIX ===\n'
python3 - <<'PY'
from pathlib import Path

path = Path("server/matilda-chat-workflow.ts")
text = path.read_text()

old = '''        payload: {
          ...persistedDraft,
        },
'''

new = '''        payload: {
          ...persistedDraft,
          evidence_entry_ids:
            JSON.stringify(
              persistedDraft.evidence_entry_ids,
            ),
        },
'''

if text.count(old) != 1:
    raise SystemExit(
        "FAIL CLOSED: expected exactly one Living Draft historical payload anchor"
    )

path.write_text(text.replace(old, new, 1))
PY

printf '\n=== VERIFY EXACT PRODUCT DIFF ===\n'
git diff --check -- "$WORKFLOW"
git diff -- "$WORKFLOW"

printf '\n=== TYPECHECK ===\n'
TSC_STATUS=0
npx tsc --noEmit || TSC_STATUS=$?
printf 'TSC_STATUS=%s\n' "$TSC_STATUS"

printf '\n=== ATLAS REGRESSION TESTS ===\n'
PERSISTENCE_STATUS=0
ADAPTER_STATUS=0
AGGREGATOR_STATUS=0
ROUTE_STATUS=0

npx tsx --test \
  db/atlas-historical-observation-persistence.test.ts \
  || PERSISTENCE_STATUS=$?

npx tsx --test \
  server/atlas/atlas-historical-observation-adapter.test.ts \
  || ADAPTER_STATUS=$?

npx tsx --test \
  server/atlas/atlas-preexecution-observation-aggregator.test.ts \
  || AGGREGATOR_STATUS=$?

npx tsx --test \
  server/routes/atlas/preexecution.test.ts \
  || ROUTE_STATUS=$?

printf '\n=== VERIFY PROTECTED BOUNDARIES ===\n'
PROTECTED_STATUS=0
git diff --exit-code -- \
  db/matilda-living-draft-runtime.ts \
  db/package-read-repository.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-draft-approval-observation.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts \
  || PROTECTED_STATUS=$?

printf 'PROTECTED_STATUS=%s\n' "$PROTECTED_STATUS"

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== CLASSIFICATION ===\n'
if [ "$TSC_STATUS" -eq 0 ] && \
   [ "$PERSISTENCE_STATUS" -eq 0 ] && \
   [ "$ADAPTER_STATUS" -eq 0 ] && \
   [ "$AGGREGATOR_STATUS" -eq 0 ] && \
   [ "$ROUTE_STATUS" -eq 0 ] && \
   [ "$PROTECTED_STATUS" -eq 0 ]; then
  echo "ATLAS_SNAPSHOT_SERIALIZATION_FIX=VALIDATED_LOCAL_ONLY"
  echo "AUTHORIZED_PRODUCT_PATH_ONLY=YES"
  echo "AUTHORITY_CHANGE=NO"
  echo "CLEAR_STOPPING_POINT=YES"
  echo "NEXT_GATE=PRODUCT_COMMIT_AND_PUSH_AUTHORIZATION"
else
  echo "ATLAS_SNAPSHOT_SERIALIZATION_FIX=FAILED_OR_BLOCKED"
  echo "CLEAR_STOPPING_POINT=YES"
  echo "NEXT_ACTION=DIAGNOSE_THIS_FIX_WITHOUT_ADDITIONAL_MUTATION"
fi

printf '\n=== PRODUCT STATUS ===\n'
git status --short -- "$WORKFLOW"

printf '\n=== STOP ===\n'
echo "PRODUCT_COMMIT_AUTHORIZED=NO"
echo "PRODUCT_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "NO PRODUCT COMMIT / NO PRODUCT PUSH"
