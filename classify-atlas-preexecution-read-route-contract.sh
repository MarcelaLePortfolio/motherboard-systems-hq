#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="d09d3bcb2"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS PRE-EXECUTION READ ROUTE CONTRACT CLASSIFICATION ====="
echo "MODE=READ_ONLY_COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "BASELINE=$(git rev-parse HEAD)"

echo
echo "===== VERIFIED INPUT CONTRACT ====="
grep -n -A70 -B15 \
  'readAtlasTypedPreexecutionObservations' \
  server/atlas/atlas-preexecution-observation-aggregator.ts

echo
echo "===== VERIFIED REASONER CONTRACT ====="
sed -n '1,260p' \
  server/atlas/atlas-preexecution-structural-reasoner.ts

echo
echo "===== ROUTE MOUNTING PATTERNS ====="
grep -RniE -B15 -A45 \
  'atlasRouter|/atlas|routes/atlas|server/routes/atlas|app\.use|router\.(get|post)' \
  server routes \
  --include='*.ts' \
  2>/dev/null | head -n 1800 || true

echo
echo "===== EXISTING EXECUTION ATLAS CONTRACTS ====="
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
echo "===== CONTRACT CLASSIFICATION ====="
echo "ROUTE_CLASS=NEW_DEDICATED_READ_ONLY_PREEXECUTION_ROUTE"
echo "EXISTING_EXECUTION_ROUTE_EXTENSION=NO"
echo "HTTP_MUTATION=NO"
echo "PROJECT_SCOPE=REQUIRED"
echo "CONVERSATION_SCOPE=REQUIRED"
echo "SOURCE_READER=readAtlasTypedPreexecutionObservations"
echo "STRUCTURAL_REASONER=reasonOverAtlasPreExecutionObservations"
echo "MODEL_CALL=NO"
echo "PERSISTENCE=NO"
echo "EXECUTION_EVENT_INPUT=NO"
echo "CAUSAL_GRAPH_INPUT=NO"
echo "APPROVAL_INFERENCE=NO"
echo "AUTHORITY_INFERENCE=NO"
echo "RAW_SOURCE_AUTHORITY_STATES=PRESERVED"
echo "MATILDA_INTERPRETIVE_AUTHORSHIP=PRESERVED"
echo "UI_REQUIRED_FOR_FIRST_UNIT=NO"
echo "FIRST_UNIT=SERVER_READ_CONTRACT_ONLY"

echo
echo "===== RESPONSE BOUNDARY ====="
echo "RESPONSE_MAY_INCLUDE=PROJECT_ID"
echo "RESPONSE_MAY_INCLUDE=SCOPED_STRUCTURAL_OBSERVATIONS"
echo "RESPONSE_MAY_INCLUDE=EXPLICIT_LINEAGE_SEQUENCES"
echo "RESPONSE_MAY_INCLUDE=SOURCE_SEQUENCE"
echo "RESPONSE_MAY_INCLUDE=AUTHORITY_SEQUENCE"
echo "RESPONSE_MUST_NOT_INCLUDE=INFERRED_CAUSAL_CHAIN"
echo "RESPONSE_MUST_NOT_INCLUDE=INFERRED_APPROVAL"
echo "RESPONSE_MUST_NOT_INCLUDE=EXECUTION_HISTORY_COERCION"
echo "RESPONSE_MUST_NOT_INCLUDE=MODEL_GENERATED_EXPLANATION"

echo
echo "===== FAILURE CONTRACT ====="
echo "MISSING_PROJECT_ID=FAIL_CLOSED"
echo "MISSING_CONVERSATION_ID=FAIL_CLOSED"
echo "CROSS_PROJECT_OBSERVATION=FAIL_CLOSED"
echo "EMPTY_OBSERVATION_SET=VALID_EMPTY_STRUCTURAL_RESULT"

echo
echo "===== IMPLEMENTATION BOUNDARY ====="
echo "MINIMUM_SAFE_IMPLEMENTATION=DEDICATED_READ_ONLY_ROUTE_PLUS_ROUTE_TESTS"
echo "AGGREGATOR_CHANGE=NOT_REQUIRED_BY_CURRENT_EVIDENCE"
echo "STRUCTURAL_REASONER_CHANGE=NOT_REQUIRED_BY_CURRENT_EVIDENCE"
echo "EXECUTION_REASONER_CHANGE=FORBIDDEN"
echo "MATILDA_CHANGE=FORBIDDEN"
echo "DATABASE_CHANGE=FORBIDDEN"
echo "UI_CHANGE=DEFERRED"
echo "DOGFOOD_CLEANUP=FROZEN"

echo
echo "===== AUTHORIZATION STATUS ====="
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=REQUEST_EXPLICIT_AUTHORIZATION_FOR_MINIMUM_READ_ONLY_ROUTE"

echo
echo "===== WORKTREE ====="
git status --short
