#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="c6f73f8fa"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS PRE-EXECUTION HTTP MOUNT / PRESENTATION BOUNDARY ====="
echo "MODE=READ_ONLY_COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "READ_ROUTE_UNIT=CLOSED"
echo "CHECKPOINT=$(git rev-parse HEAD)"

echo
echo "===== PRE-EXECUTION READ ROUTE ====="
sed -n '1,260p' server/routes/atlas/preexecution.ts

echo
echo "===== CURRENT SERVER ROUTE MOUNTS ====="
grep -RniE -B20 -A50 \
  'atlas/analyze|atlas/why|routes/atlas|app\.use|router\.use|import .*atlas' \
  server \
  --include='*.ts' \
  2>/dev/null | head -n 2200 || true

echo
echo "===== CURRENT OPERATOR PRESENTATION REFERENCES ====="
grep -RniE -B15 -A70 \
  'Atlas|atlas|preexecution|pre-execution|lineageSequences|authoritySequence|sourceSequence' \
  public src client \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.js' \
  --include='*.jsx' \
  --include='*.html' \
  2>/dev/null | head -n 2400 || true

echo
echo "===== CLASSIFICATION QUESTIONS ====="
echo "Q1=WHERE_ARE_EXISTING_ATLAS_ROUTERS_MOUNTED"
echo "Q2=WHAT_IS_THE_MINIMUM_SAFE_HTTP_PATH_FOR_PREEXECUTION_READS"
echo "Q3=SHOULD_HTTP_METHOD_BE_GET_WITH_REQUIRED_PROJECT_ID_AND_CONVERSATION_ID_QUERY_PARAMS"
echo "Q4=WHAT_ERROR_STATUS_SHOULD_MISSING_SCOPE_RETURN"
echo "Q5=CAN_ROUTE_BE_MOUNTED_WITHOUT_CHANGING_EXISTING_ATLAS_ANALYZE_OR_WHY_BEHAVIOR"
echo "Q6=IS_OPERATOR_UI_PRESENTATION_REQUIRED_NOW_OR_CAN_HTTP_MOUNT_CLOSE_FIRST"
echo "Q7=WHAT_RESPONSE_LABELING_PREVENTS_PREEXECUTION_FROM_LOOKING_LIKE_EXECUTION_OR_CAUSAL_OUTPUT"
echo "Q8=WHAT_MINIMUM_ROUTE_MOUNT_TEST_PROVES_EXISTING_EXECUTION_ENDPOINTS_REMAIN_UNCHANGED"

echo
echo "===== HARD INVARIANTS ====="
echo "EXISTING_ATLAS_ANALYZE_CHANGE=FORBIDDEN"
echo "EXISTING_ATLAS_WHY_CHANGE=FORBIDDEN"
echo "EXECUTION_EVENT_COERCION=FORBIDDEN"
echo "CAUSAL_LABELING_FOR_PREEXECUTION=FORBIDDEN"
echo "AUTHORITY_COLLAPSE=FORBIDDEN"
echo "MATILDA_AUTHORSHIP_ERASURE=FORBIDDEN"
echo "MODEL_CALL=FORBIDDEN"
echo "PERSISTENCE=FORBIDDEN"
echo "WRITE_METHOD=FORBIDDEN"
echo "UI_CHANGE=NOT_AUTHORIZED"

echo
echo "===== STOP BOUNDARY ====="
echo "SERVER_MOUNT_CHANGE=NONE"
echo "ROUTE_CHANGE=NONE"
echo "UI_CHANGE=NONE"
echo "REASONER_CHANGE=NONE"
echo "AGGREGATOR_CHANGE=NONE"
echo "MATILDA_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "IMPLEMENTATION=NONE"
echo "DOGFOOD_CLEANUP=FROZEN"
echo "NEXT_ACTION=CLASSIFY_MINIMUM_HTTP_MOUNT_CONTRACT"

echo
echo "===== WORKTREE ====="
git status --short
