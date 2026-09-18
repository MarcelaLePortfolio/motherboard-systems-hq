#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== CHECKPOINT ===\n'
printf 'HEAD='
git rev-parse --short=9 HEAD
echo "PREVIOUS_FAILED_HYPOTHESIS_SEQUENCE=CLOSED"
echo "CONFIRMED_MISMATCH=LIVE_STRING_ARRAY_VS_ATLAS_STRING"
echo "IMPLEMENTATION_AUTHORIZED=NO"

printf '\n=== DATABASE READ MODEL REPRESENTATION ===\n'
grep -R -n -A20 -B10 \
  'export type LivingDraftPackageReadRecord\|interface LivingDraftPackageReadRecord' \
  db/package-read-repository.ts \
  db \
  | head -n 160 || true

printf '\n=== PACKAGE READ REPOSITORY EVIDENCE FIELD ===\n'
grep -n -A12 -B12 \
  'evidence_entry_ids' \
  db/package-read-repository.ts \
  | head -n 180 || true

printf '\n=== LIVE ATLAS ADAPTER REPRESENTATION ===\n'
sed -n '1,150p' server/atlas/atlas-draft-approval-observation.ts

printf '\n=== LIVE ATLAS ADAPTER TEST REPRESENTATION ===\n'
sed -n '1,90p' server/atlas/atlas-draft-approval-observation.test.ts

printf '\n=== HISTORICAL ADAPTER REPRESENTATION ===\n'
sed -n '190,255p' server/atlas/atlas-historical-observation-adapter.ts

printf '\n=== HISTORICAL ADAPTER TEST REPRESENTATION ===\n'
sed -n '90,180p' server/atlas/atlas-historical-observation-adapter.test.ts

printf '\n=== WORKFLOW SNAPSHOT INPUT REPRESENTATION ===\n'
sed -n '548,590p' server/matilda-chat-workflow.ts
sed -n '430,465p' db/matilda-living-draft-runtime.ts

printf '\n=== SEARCH NORMALIZATION PRECEDENT ===\n'
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  'JSON.stringify.*evidence_entry_ids\|evidence_entry_ids.*JSON.stringify\|evidenceEntryIds' \
  server db \
  | head -n 250 || true

printf '\n=== NORMALIZATION OWNERSHIP CLASSIFICATION ===\n'
echo "LIVE_DRAFT_RUNTIME_CONTRACT=STRING_ARRAY"
echo "PERSISTED_DRAFT_DATABASE_CONTRACT=JSON_STRING"
echo "EXISTING_ATLAS_LIVE_OBSERVATION_CONTRACT=STRING"
echo "EXISTING_ATLAS_HISTORICAL_OBSERVATION_CONTRACT=STRING"
echo "HISTORICAL_SNAPSHOT_INPUT_CURRENTLY=LIVE_RUNTIME_RECORD"
echo "PREFERRED_BOUNDARY_IF_CONFIRMED=SNAPSHOT_SERIALIZATION"
echo "REASON=HISTORICAL_SNAPSHOT_SHOULD_PRESERVE_ESTABLISHED_ATLAS_SOURCE_REPRESENTATION_WITHOUT_CHANGING_LIVE_DRAFT_RUNTIME_OR_ATLAS_READ_MODEL"
echo "IMPLEMENTATION_AUTHORIZED=NO"

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

printf '\n=== STOP ===\n'
echo "PRODUCT_MUTATION=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "ATTEMPT_4_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "PRODUCTION_DATABASE_MUTATION_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=DEFINE_NARROW_SNAPSHOT_SERIALIZATION_FIX_IF_CONTRACT_EVIDENCE_CONFIRMS"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
