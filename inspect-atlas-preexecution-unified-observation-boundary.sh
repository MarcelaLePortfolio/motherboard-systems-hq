#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="5a53bebe1"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS PRE-EXECUTION UNIFIED OBSERVATION — BOUNDARY INVESTIGATION ====="
echo "MODE=READ_ONLY_COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "IEL_ADAPTER_UNIT=CLOSED"
echo "LIVING_DRAFT_PENDING_APPROVAL_ADAPTER_UNIT=CLOSED"
echo "CANONICAL_PACKAGE_ADAPTER_UNIT=CLOSED"
echo "CHECKPOINT=$(git rev-parse HEAD)"

echo
echo "===== CURRENT PRE-EXECUTION OBSERVATION TYPES ====="
sed -n '1,320p' server/atlas/atlas-preexecution-read-model.ts
sed -n '1,360p' server/atlas/atlas-draft-approval-observation.ts
sed -n '1,320p' server/atlas/atlas-canonical-package-observation.ts

echo
echo "===== CURRENT EXECUTION-ONLY ATLAS REASONING SURFACES ====="
sed -n '1,320p' server/atlas/atlas-unified-engine.ts 2>/dev/null || true
sed -n '1,320p' server/atlas/narrative-engine.ts 2>/dev/null || true
sed -n '1,320p' server/atlas/atlas-reconstruction-model.ts 2>/dev/null || true
sed -n '1,320p' server/atlas/causal-graph.ts 2>/dev/null || true
sed -n '1,320p' server/atlas/session-cluster.ts 2>/dev/null || true

echo
echo "===== EXECUTION EVENT CONTRACT ====="
sed -n '1,260p' server/events/execution-event-bus.ts 2>/dev/null || true

echo
echo "===== ROUTE INPUT BOUNDARIES ====="
sed -n '1,300p' server/routes/atlas/analyze.ts 2>/dev/null || true
sed -n '1,300p' server/routes/atlas/why.ts 2>/dev/null || true
sed -n '1,300p' routes/atlas/why.ts 2>/dev/null || true

echo
echo "===== CLASSIFICATION QUESTIONS ====="
echo "Q1=WHAT_COMMON_FIELDS_CAN_BE_UNIFIED_WITHOUT_ERASING_SOURCE_TYPE"
echo "Q2=HOW_SHOULD_AUTHORITY_STATE_BE_REPRESENTED_ACROSS_IEL_DRAFT_PENDING_AND_CANONICAL"
echo "Q3=SHOULD_UNIFIED_PREEXECUTION_OBSERVATIONS_REMAIN_PARALLEL_TO_EXECUTION_EVENTS"
echo "Q4=WHICH_REASONER_IS_THE_NARROWEST_SAFE_FIRST_CONSUMER"
echo "Q5=CAN_TRAJECTORY_AND_CAUSAL_REASONING_ACCEPT_PREEXECUTION_INPUT_WITHOUT_SEMANTIC_COERCION"
echo "Q6=WHAT_CHRONOLOGY_RULES_ARE_REQUIRED_ACROSS_CREATED_UPDATED_APPROVAL_TIMESTAMPS"
echo "Q7=WHAT_SOURCE_REFERENCES_AND_LINEAGE_FIELDS_MUST_REMAIN_TYPED"
echo "Q8=WHAT_MINIMUM_NEXT_UNIT_CAN_BE_VALIDATED_WITH_EXISTING_EXECUTION_BEHAVIOR_UNCHANGED"

echo
echo "===== INVARIANTS ====="
echo "PREEXECUTION_AS_EXECUTION_EVENT=FORBIDDEN"
echo "SOURCE_TYPE_ERASURE=FORBIDDEN"
echo "AUTHORITY_STATE_COLLAPSE=FORBIDDEN"
echo "MATILDA_AUTHORSHIP_ERASURE=FORBIDDEN"
echo "DRAFT_PROMOTION=FORBIDDEN"
echo "PENDING_APPROVAL_PROMOTION=FORBIDDEN"
echo "CANONICAL_AUTHORITY_DOWNGRADE=FORBIDDEN"
echo "EXISTING_EXECUTION_REASONING_REGRESSION=FORBIDDEN"
echo "SECOND_MODEL_CALL=FORBIDDEN"
echo "NEW_PERSISTENCE=FORBIDDEN"

echo
echo "===== STOP BOUNDARY ====="
echo "SOURCE_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "MATILDA_CHANGE=NONE"
echo "APPROVAL_CHANGE=NONE"
echo "OPERATIONAL_AUTHORITY_CHANGE=NONE"
echo "ATLAS_REASONER_WIRING=NONE"
echo "IMPLEMENTATION=NONE"
echo "DOGFOOD_CLEANUP=FROZEN"
echo "NEXT_ACTION=CLASSIFY_UNIFIED_PREEXECUTION_OBSERVATION_AND_REASONER_INTEGRATION_BOUNDARY"

echo
echo "===== WORKTREE ====="
git status --short
