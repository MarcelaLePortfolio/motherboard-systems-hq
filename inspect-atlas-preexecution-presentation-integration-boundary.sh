#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="923062ad1"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS PRE-EXECUTION PRESENTATION INTEGRATION — BOUNDARY INVESTIGATION ====="
echo "MODE=READ_ONLY_COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "STRUCTURAL_REASONER=CLOSED"
echo "CHECKPOINT=$(git rev-parse HEAD)"

echo
echo "===== STRUCTURAL REASONER ====="
sed -n '1,320p' server/atlas/atlas-preexecution-structural-reasoner.ts

echo
echo "===== AGGREGATOR ====="
sed -n '1,360p' server/atlas/atlas-preexecution-observation-aggregator.ts

echo
echo "===== CURRENT ATLAS ROUTES ====="
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
echo "===== CURRENT ATLAS PRESENTATION / CLIENT REFERENCES ====="
grep -RniE -B12 -A60 \
  'atlas/analyze|atlas/why|Atlas|globalSummary|sessionReasoning|causalChain|lineageSequences|pre-execution|preexecution' \
  public src client server routes \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.js' \
  --include='*.jsx' \
  --include='*.html' \
  2>/dev/null | head -n 2400 || true

echo
echo "===== CLASSIFICATION QUESTIONS ====="
echo "Q1=SHOULD_PREEXECUTION_STRUCTURAL_OUTPUT_USE_A_NEW_READ_ONLY_ROUTE_OR_EXTEND_AN_EXISTING_ATLAS_ROUTE"
echo "Q2=CAN_EXISTING_EXECUTION_ROUTE_RESPONSE_SHAPES_REMAIN_UNCHANGED"
echo "Q3=WHAT_PROJECT_AND_CONVERSATION_SCOPE_MUST_THE_ROUTE_REQUIRE"
echo "Q4=SHOULD_ROUTE_OUTPUT_EXPOSE_RAW_TYPED_OBSERVATIONS_OR_ONLY_STRUCTURAL_REASONING_RESULT"
echo "Q5=HOW_SHOULD_MATILDA_AUTHORED_INTERPRETIVE_EVIDENCE_BE_LABELED_AT_PRESENTATION_BOUNDARY"
echo "Q6=HOW_SHOULD_NON_AUTHORITATIVE_PENDING_AND_AUTHORITATIVE_STATES_BE_PRESENTED_WITHOUT_COLLAPSE"
echo "Q7=IS_UI_WIRING_REQUIRED_FOR_THE_FIRST_INTEGRATION_UNIT"
echo "Q8=WHAT_IS_THE_SMALLEST_SAFE_OPERATOR_VISIBLE_READ_PATH"

echo
echo "===== HARD INVARIANTS ====="
echo "EXISTING_EXECUTION_ROUTE_SEMANTICS_CHANGE=FORBIDDEN_DURING_INVESTIGATION"
echo "PREEXECUTION_AS_EXECUTION_HISTORY=FORBIDDEN"
echo "PREEXECUTION_AS_CAUSAL_EXPLANATION=FORBIDDEN"
echo "AUTHORITY_STATE_COLLAPSE=FORBIDDEN"
echo "MATILDA_AUTHORSHIP_ERASURE=FORBIDDEN"
echo "APPROVAL_INFERENCE=FORBIDDEN"
echo "EXECUTION_EVENT_COERCION=FORBIDDEN"
echo "SECOND_MODEL_CALL=FORBIDDEN"
echo "NEW_PERSISTENCE=FORBIDDEN"
echo "WRITE_ROUTE=FORBIDDEN"

echo
echo "===== STOP BOUNDARY ====="
echo "SOURCE_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "ROUTE_CHANGE=NONE"
echo "UI_CHANGE=NONE"
echo "REASONER_CHANGE=NONE"
echo "MATILDA_CHANGE=NONE"
echo "EXECUTION_EVENT_CHANGE=NONE"
echo "IMPLEMENTATION=NONE"
echo "DOGFOOD_CLEANUP=FROZEN"
echo "NEXT_ACTION=CLASSIFY_MINIMUM_OPERATOR_VISIBLE_PREEXECUTION_READ_PATH"

echo
echo "===== WORKTREE ====="
git status --short
