#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="e0646e556"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS PRE-EXECUTION REASONING — BOUNDARY INVESTIGATION ====="
echo "MODE=READ_ONLY_COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "TYPED_PREEXECUTION_AGGREGATOR=CLOSED"
echo "CHECKPOINT=$(git rev-parse HEAD)"

echo
echo "===== TYPED PRE-EXECUTION AGGREGATOR ====="
sed -n '1,360p' server/atlas/atlas-preexecution-observation-aggregator.ts

echo
echo "===== CURRENT ATLAS REASONING SURFACES ====="
for file in \
  server/atlas/atlas-unified-engine.ts \
  server/atlas/atlas-reconstruction-model.ts \
  server/atlas/narrative-engine.ts \
  server/atlas/session-aware-reasoner.ts \
  server/atlas/causal-graph.ts \
  server/atlas/session-cluster.ts \
  server/atlas/temporal-decay.ts
do
  echo
  echo "----- $file -----"
  sed -n '1,360p' "$file" 2>/dev/null || true
done

echo
echo "===== ATLAS ROUTES ====="
for file in \
  server/routes/atlas/analyze.ts \
  server/routes/atlas/why.ts \
  routes/atlas/why.ts
do
  echo
  echo "----- $file -----"
  sed -n '1,320p' "$file" 2>/dev/null || true
done

echo
echo "===== SEARCH FOR NON-EXECUTION REASONING EXTENSION POINTS ====="
grep -RniE -B15 -A80 \
  'observation|trajectory|narrative|reason|reconstruct|causal|session|context|history|timeline|intelligence' \
  server/atlas docs/governance \
  --include='*.ts' \
  --include='*.md' \
  2>/dev/null | head -n 2400 || true

echo
echo "===== CLASSIFICATION QUESTIONS ====="
echo "Q1=WHAT_REASONING_OUTPUT_CAN_BE_DERIVED_FROM_TYPED_PREEXECUTION_OBSERVATIONS_WITHOUT_EXECUTION_SEMANTICS"
echo "Q2=SHOULD_FIRST_REASONING_LAYER_BE_SEPARATE_FROM_RUN_ATLAS_INTELLIGENCE"
echo "Q3=CAN_PREEXECUTION_REASONING_BE_DETERMINISTIC_WITHOUT_MODEL_CALL"
echo "Q4=WHAT_RELATIONSHIPS_CAN_BE_STATED_FROM_SHARED_LINEAGE_AND_CHRONOLOGY_WITHOUT_INFERRED_CAUSATION"
echo "Q5=HOW_SHOULD_AUTHORITY_TRANSITIONS_BE_REPORTED_WITHOUT_ATLAS_BECOMING_AUTHORITY"
echo "Q6=HOW_SHOULD_IEL_MATILDA_AUTHORED_INTERPRETATION_BE_DISTINGUISHED_FROM_DURABLE_FACTS"
echo "Q7=WHAT_IS_THE_NARROWEST_SAFE_FIRST_PREEXECUTION_REASONING_OUTPUT"
echo "Q8=CAN_EXISTING_EXECUTION_ANALYSIS_REMAIN_BYTE_FOR_BYTE_UNTOUCHED_IN_THE_FIRST_REASONING_UNIT"

echo
echo "===== HARD INVARIANTS ====="
echo "PREEXECUTION_AS_EXECUTION_EVENT=FORBIDDEN"
echo "CHRONOLOGY_AS_CAUSATION=FORBIDDEN"
echo "ATLAS_AUTHORITY_CREATION=FORBIDDEN"
echo "ATLAS_APPROVAL_INFERENCE=FORBIDDEN"
echo "MATILDA_AUTHORSHIP_ERASURE=FORBIDDEN"
echo "LIVING_DRAFT_PROMOTION=FORBIDDEN"
echo "PENDING_APPROVAL_PROMOTION=FORBIDDEN"
echo "CANONICAL_AUTHORITY_DOWNGRADE=FORBIDDEN"
echo "CURRENT_EXECUTION_REASONERS_CHANGE=FORBIDDEN_DURING_INVESTIGATION"
echo "SECOND_MODEL_CALL=FORBIDDEN"
echo "NEW_PERSISTENCE=FORBIDDEN"

echo
echo "===== STOP BOUNDARY ====="
echo "SOURCE_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "ROUTE_CHANGE=NONE"
echo "REASONER_CHANGE=NONE"
echo "MATILDA_CHANGE=NONE"
echo "EXECUTION_EVENT_CHANGE=NONE"
echo "IMPLEMENTATION=NONE"
echo "DOGFOOD_CLEANUP=FROZEN"
echo "NEXT_ACTION=CLASSIFY_MINIMUM_ATLAS_PREEXECUTION_REASONING_CONTRACT"

echo
echo "===== WORKTREE ====="
git status --short
