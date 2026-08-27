#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT EXISTING MATILDA EXECUTION AUTHORIZATION AUTHORITY ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="48d8c7b7a"
CURRENT_HEAD="$(git rev-parse HEAD)"

if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== INSPECT EXECUTION AUTHORIZATION ROUTE ==="
sed -n '1,220p' server/routes/matilda-execution-authorization-route.ts

echo
echo "=== INSPECT EXECUTION AUTHORIZATION RUNTIME ==="
sed -n '1,280p' db/matilda-execution-authorization-runtime.ts

echo
echo "=== INSPECT PREVIEW CONFIRMATION PREDECESSOR ==="
sed -n '1,240p' server/routes/matilda-preview-confirmation-route.ts
sed -n '1,260p' db/matilda-preview-confirmation-runtime.ts

echo
echo "=== INSPECT EXECUTION PLANNING PREDECESSOR ==="
sed -n '1,240p' server/routes/matilda-execution-planning-route.ts
sed -n '1,280p' db/matilda-execution-planning-runtime.ts

echo
echo "=== FIND ROUTE CLIENT / UI REACHABILITY ==="
git grep -n -I -E \
  '/api/matilda/execution-authorization|execution-authorization|execution_authorized' \
  -- \
  client/src server routes db \
  ':!server/operational/*' \
  ':!server/execution/smoke-test-*' \
  | sed -n '1,1000p' || true

echo
echo "=== FIND EXECUTION AUTHORIZATION TABLE / WRITE SHAPE ==="
git grep -n -I -E \
  'execution_authorization|execution_authorized|approved_by|authorized_by|user_actor|actor_id|actor_type|envelope_id|approval_id' \
  -- \
  db/matilda-execution-authorization-runtime.ts \
  server/routes/matilda-execution-authorization-route.ts \
  db/governance-runtime.ts \
  | sed -n '1,1000p' || true

echo
echo "=== FIND CALLERS OF createExecutionAuthorization ==="
git grep -n -I 'createExecutionAuthorization' -- . || true

echo
echo "=== CLASSIFICATION TARGET ==="
echo "DETERMINE_1=WHETHER_EXISTING_EXECUTION_AUTHORIZATION_IS_ALREADY_THE_CANONICAL_DURABLE_AUTHORITY_STORE"
echo "DETERMINE_2=WHETHER_ROUTE_REQUIRES_EXPLICIT_USER_CONFIRMATION_OR_ACCEPTS_UNTRUSTED_CALLER_ASSERTION"
echo "DETERMINE_3=WHETHER_AUTHORIZATION_BINDS_TO_EXACT_PREVIEW_PLAN_PACKAGE_OR_ENVELOPE"
echo "DETERMINE_4=WHETHER_AUTHORIZATION_RECORDS_USER_ACTOR_PROVENANCE"
echo "DETERMINE_5=WHETHER_EXISTING_RUNTIME_CAN_BE_REUSED_WITHOUT_NEW_APPROVAL_TABLE"
echo "DETERMINE_6=WHETHER_APPROVAL_ARTIFACT_CAN_BE_COMPILED_FROM_THIS_DURABLE_AUTHORIZATION"
echo "DETERMINE_7=WHETHER_ANY_MODEL_OR_AGENT_PATH_CAN_SELF_AUTHORIZE"
echo "DETERMINE_8=SMALLEST_PROVEN_GAP_BETWEEN_EXISTING_AUTHORIZATION_AND_EXECUTION_APPROVAL_GATE"

echo
echo "=== PRESERVED INVARIANTS ==="
echo "CANONICAL_PACKAGE_APPROVAL_IS_NOT_EXECUTION_APPROVAL=YES"
echo "USER_IS_EXECUTION_APPROVAL_AUTHORITY=YES"
echo "MATILDA_SELF_APPROVAL=PROHIBITED"
echo "CADE_SELF_APPROVAL=PROHIBITED"
echo "PARALLEL_GENERAL_APPROVAL_SYSTEM=PROHIBITED"
echo "EXECUTION_APPROVAL_MUST_BE_EXACTLY_BOUND=YES"
echo "EXECUTION_APPROVAL_MUST_FAIL_CLOSED=YES"

echo
echo "=== BOUNDARIES ==="
echo "NO_PRODUCTION_FILE_EDIT=YES"
echo "NO_APPROVAL_WRITE=YES"
echo "NO_DATABASE_SCHEMA_WRITE=YES"
echo "NO_EXECUTION_AUTHORIZATION_WRITE=YES"
echo "NO_GIT_EFFECT=YES"
echo "NO_REMOTE_WRITE=YES"

echo
echo "=== NEXT ACTION ==="
echo "NEXT_ACTION=CLASSIFY_EXISTING_EXECUTION_AUTHORIZATION_RUNTIME_BEFORE_DESIGNING_ANY_NEW_WRITE_SURFACE"
