#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY TRUSTED IDENTITY GAP AFTER AUTHORIZATION BOUNDARY ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="1ca403b8a"
CURRENT_HEAD="$(git rev-parse HEAD)"

if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== INSPECT EXECUTION AUTHORIZATION ROUTE EXACTLY ==="
sed -n '1,180p' server/routes/matilda-execution-authorization-route.ts

echo
echo "=== INSPECT EXECUTION AUTHORIZATION PERSISTENCE EXACTLY ==="
sed -n '1,240p' db/matilda-execution-authorization-runtime.ts

echo
echo "=== INSPECT PREVIEW CONFIRMATION PERSISTENCE ==="
sed -n '1,220p' db/matilda-preview-confirmation-runtime.ts

echo
echo "=== INSPECT PREVIEW PERSISTENCE ==="
sed -n '1,220p' db/matilda-preview-runtime.ts

echo
echo "=== INSPECT EXECUTION PLANNING PERSISTENCE ==="
sed -n '1,220p' db/matilda-execution-planning-runtime.ts

echo
echo "=== SEARCH SERVER VERIFIED USER IDENTITY ==="
git grep -n -I -E \
  'req\.user|request\.user|res\.locals\.(user|session|actor)|session\.(user|actor)|authenticatedUser|authenticated_user|currentUser|current_user|verified_actor|verifiedActor' \
  -- server routes db \
  || true

echo
echo "=== SEARCH AUTH MIDDLEWARE / SESSION INSTALLATION ==="
git grep -n -I -E \
  'passport|express-session|sessionMiddleware|authMiddleware|authenticate|authentication middleware|requireAuth|requireUser|isAuthenticated' \
  -- server routes package.json pnpm-lock.yaml \
  || true

echo
echo "=== SEARCH EXECUTION AUTHORIZATION ACTOR SOURCE ==="
git grep -n -I -E \
  'authorization_actor|authorized_by|approved_by|actor_id|user_id' \
  -- server/routes/matilda-execution-authorization-route.ts \
  db/matilda-execution-authorization-runtime.ts \
  db/matilda-preview-confirmation-runtime.ts \
  db/matilda-preview-runtime.ts \
  db/matilda-execution-planning-runtime.ts \
  || true

echo
echo "=== VERIFY LINEAGE EXISTS ==="
git grep -n -I -E \
  'confirmation_id|preview_id|execution_plan_id' \
  -- server/routes/matilda-execution-authorization-route.ts \
  db/matilda-execution-authorization-runtime.ts \
  db/matilda-preview-confirmation-runtime.ts \
  db/matilda-preview-runtime.ts \
  db/matilda-execution-planning-runtime.ts

echo
echo "=== CLASSIFICATION ==="
echo "DURABLE_EXECUTION_AUTHORIZATION_RUNTIME_EXISTS=YES"
echo "EXECUTION_AUTHORIZATION_ROUTE_EXISTS=YES"
echo "PREVIEW_CONFIRMATION_PLAN_LINEAGE_EXISTS=YES"
echo "EXISTING_APPROVAL_GATE_AND_VERSION_CONTROL_EFFECTS_EXIST=YES"
echo "TRUSTED_USER_IDENTITY_SOURCE=UNRESOLVED_FROM_PRIOR_EVIDENCE"
echo "REQUEST_BODY_ACTOR_MUST_NOT_BE_PROMOTED_TO_AUTHORITY=YES"

echo
echo "=== DECISION RULE ==="
echo "IF_SERVER_VERIFIED_IDENTITY_FOUND=CLASSIFY_SINGLE_AUTHORIZATION_COMPILATION_UNIT"
echo "IF_SERVER_VERIFIED_IDENTITY_NOT_FOUND=STOP_AND_CLASSIFY_IDENTITY_BOUNDARY_AS_SEPARATE_PREREQUISITE"
echo "DO_NOT_CREATE_PARALLEL_AUTH_SYSTEM=YES"
echo "DO_NOT_HARDCODE_USER_IDENTITY=YES"
echo "DO_NOT_TREAT_CONFIRMATION_AS_IDENTITY=YES"
echo "DO_NOT_TREAT_PREVIEW_AS_IDENTITY=YES"
echo "DO_NOT_TREAT_EXECUTION_PLAN_AS_IDENTITY=YES"

echo
echo "=== PRESERVED BOUNDARIES ==="
echo "CANONICAL_PACKAGE_APPROVAL_UNCHANGED=YES"
echo "GOVERNANCE_ENVELOPE_UNCHANGED=YES"
echo "EXECUTION_APPROVAL_GATE_UNCHANGED=YES"
echo "CADE_COMMIT_EFFECT_UNCHANGED=YES"
echo "CADE_PUSH_EFFECT_UNCHANGED=YES"
echo "GENERIC_CADE_ROUTE_UNCHANGED=YES"
echo "GENERIC_MUTATION_AUTHORITY_DISABLED=YES"
echo "GENERIC_SHELL_AUTHORITY_DISABLED=YES"
echo "AUTONOMOUS_EXECUTION_AUTHORITY_DISABLED=YES"

echo
echo "=== NEXT ACTION ==="
echo "NEXT_ACTION=CLASSIFY_TRUSTED_IDENTITY_RESULT_BEFORE_AUTHORIZING_ANY_DURABLE_USER_APPROVAL_WRITE_OR_APPROVAL_ARTIFACT_COMPILATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== SAFETY ==="
echo "NO_PRODUCTION_FILE_EDIT=YES"
echo "NO_DATABASE_SCHEMA_WRITE=YES"
echo "NO_APPROVAL_WRITE=YES"
echo "NO_EXECUTION_AUTHORIZATION_WRITE=YES"
echo "NO_GIT_EFFECT_OTHER_THAN_THIS_EVIDENCE_RECORD=YES"
echo "NO_REMOTE_RUNTIME_EFFECT=YES"
