#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
WORKFLOW="server/matilda-chat-workflow.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== CHECKPOINT ===\n'
printf 'HEAD='
git rev-parse --short=9 HEAD
echo "PREVIOUS_FAILED_HYPOTHESIS_SEQUENCE=CLOSED"
echo "NEW_SOLUTION_CLASS=HISTORICAL_SNAPSHOT_SERIALIZATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"

printf '\n=== CONFIRMED CONTRACT ===\n'
echo "LIVE_DRAFT_RUNTIME_CONTRACT=STRING_ARRAY"
echo "PERSISTED_DRAFT_DATABASE_CONTRACT=JSON_STRING"
echo "EXISTING_ATLAS_LIVE_OBSERVATION_CONTRACT=STRING"
echo "EXISTING_ATLAS_HISTORICAL_OBSERVATION_CONTRACT=STRING"
echo "NORMALIZATION_OWNER=HISTORICAL_SNAPSHOT_BOUNDARY"

printf '\n=== EXACT PROPOSED MUTATION ===\n'
cat <<'PLAN'
AUTHORIZED_PRODUCT_PATH_IF_APPROVED:
- server/matilda-chat-workflow.ts

CURRENT:
payload: {
  ...persistedDraft,
},

PROPOSED:
payload: {
  ...persistedDraft,
  evidence_entry_ids:
    JSON.stringify(
      persistedDraft.evidence_entry_ids,
    ),
},

RATIONALE:
- persistedDraft is the live runtime representation and exposes evidence_entry_ids as string[]
- the durable package/read representation exposes evidence_entry_ids as a JSON string
- the existing Atlas live observation contract consumes that string representation
- the existing Atlas historical adapter also consumes that string representation
- normalization therefore belongs where the live runtime record becomes an immutable Atlas historical snapshot
- no Living Draft runtime contract changes
- no Atlas adapter contract changes
- no authority semantics change
- no assertion weakening

VALIDATION_IF_AUTHORIZED:
1. TypeScript typecheck
2. Atlas historical persistence tests
3. Atlas historical adapter tests
4. Atlas preexecution aggregator tests
5. Atlas preexecution route tests
6. explicit-target lifecycle integration test with the previously diagnosed fixture requirements applied only as necessary to exercise the lifecycle
7. protected-boundary diff verification

NOT_AUTHORIZED:
- implementation now
- live dogfood
- production database mutation
- destructive cleanup
- scheduling changes
- routing authority changes
- orchestration authority changes
- self-authorization
- commit or push of product/test mutations without subsequent explicit authorization
PLAN

printf '\n=== VERIFY CURRENT WORKFLOW SEAM ===\n'
grep -n -A25 -B8 \
  'persistAtlasHistoricalObservation({' \
  "$WORKFLOW" \
  | tail -n 80

printf '\n=== VERIFY PRODUCT BOUNDARIES UNCHANGED ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-living-draft-runtime.ts \
  db/package-read-repository.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-draft-approval-observation.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== AUTHORIZATION GATE ===\n'
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCT_MUTATION=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo
echo "REPLY EXACTLY:"
echo "Authorize the narrow Atlas historical snapshot serialization fix in server/matilda-chat-workflow.ts to serialize only persistedDraft.evidence_entry_ids with JSON.stringify when constructing the Living Draft historical payload, preserving the live Living Draft runtime contract, Atlas observation contracts, authority semantics, and all other product behavior, with no live dogfood execution, production database mutation, destructive cleanup, scheduling, routing, orchestration, self-authorization, product commit, test commit, or push."

printf '\n=== STOP ===\n'
echo "NEXT_ACTION=WAIT_FOR_EXPLICIT_IMPLEMENTATION_AUTHORIZATION"
echo "CLEAR_STOPPING_POINT=YES"
