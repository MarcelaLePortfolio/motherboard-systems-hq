#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY EXISTING APPROVAL TRANSITION AND PROJECT IDENTITY SOURCES ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "ORCHESTRATOR_IMPLEMENTATION_AUTHORIZED=NO"
echo "ACTIVE_REPOSITORY_ENABLEMENT_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="2107e0225"
CURRENT_HEAD="$(git rev-parse HEAD)"

if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== CLOSED PREDECESSOR ==="
echo "MINIMUM_PRODUCTION_REACHABILITY_CLASSIFICATION=2107e0225"
echo "CANDIDATE_UNIT=GOVERNED_VERSION_CONTROL_ORCHESTRATOR"
echo "GENERIC_ROUTE_VERSION_CONTROL_REACHABILITY=PROHIBITED"

echo
echo "=== APPROVAL TRANSITION SOURCE SEARCH ==="
git grep -n -I -E \
  'approval_required|approval_id|approval_status|status.*approved|approved_by|approved_at|user_approval|explicit.*approval|approveExecution|approve.*execution|approval.*transition|approval.*artifact' \
  -- server routes app src docs 2>/dev/null \
  | sed -n '1,1400p' || true

echo
echo "=== APPROVAL MUTATION / PERSISTENCE SEARCH ==="
git grep -n -I -E \
  'INSERT INTO.*approval|UPDATE.*approval|approval.*store|approval.*persist|save.*approval|record.*approval|db.*approval|approval.*db' \
  -- server routes app src 2>/dev/null \
  | sed -n '1,1000p' || true

echo
echo "=== PROJECT IDENTITY SOURCE SEARCH ==="
git grep -n -I -E \
  'activeProjectId|project-registry|projectRegistry|project_registry|repo_path|repoPath|repository_path|repositoryPath|repo_url|repoUrl|repository_url|repositoryUrl|branch|remote' \
  -- server routes app src config docs 2>/dev/null \
  | sed -n '1,1600p' || true

echo
echo "=== CANDIDATE REGISTRY FILES ==="
find . \
  -path './node_modules' -prune -o \
  -path './.git' -prune -o \
  -type f \
  \( -iname '*project*registry*' -o -iname '*registry*project*' -o -iname '*project*config*' -o -iname '*workspace*config*' \) \
  -print | sort | sed -n '1,300p'

echo
echo "=== CLASSIFICATION QUESTIONS ==="
echo "QUESTION_1=IS_THERE_AN_EXISTING_RUNTIME_USER_APPROVAL_TRANSITION"
echo "QUESTION_2=IS_APPROVAL_TRANSITION_BOUND_TO_APPROVAL_ID_AND_ENVELOPE_ID"
echo "QUESTION_3=IS_APPROVAL_STATE_DURABLE_OR_REQUEST_SCOPED"
echo "QUESTION_4=CAN_MODEL_OUTPUT_OR_INTERNAL_AGENT_STATE_SELF_APPROVE"
echo "QUESTION_5=DOES_PROJECT_REGISTRY_OWN_CANONICAL_REPO_PATH"
echo "QUESTION_6=DOES_PROJECT_REGISTRY_OWN_CANONICAL_BRANCH"
echo "QUESTION_7=DOES_PROJECT_REGISTRY_OWN_CANONICAL_REMOTE_NAME"
echo "QUESTION_8=DOES_PROJECT_REGISTRY_OWN_CANONICAL_REMOTE_URL"
echo "QUESTION_9=CAN_PROJECT_TARGET_BE_DERIVED_WITHOUT_MODEL_INFERENCE"
echo "QUESTION_10=WHAT_IS_THE_SMALLEST_MISSING_SOURCE_OF_TRUTH"

echo
echo "=== DECISION RULES ==="
echo "IF_EXISTING_APPROVAL_TRANSITION_IS_COMPLETE=REUSE_IT"
echo "IF_EXISTING_APPROVAL_TRANSITION_IS_PARTIAL=PATCH_ONLY_PROVEN_GAP"
echo "IF_NO_APPROVAL_TRANSITION_EXISTS=CLASSIFY_NEW_NARROW_APPROVAL_TRANSITION_UNIT_BEFORE_ORCHESTRATOR"
echo "IF_PROJECT_REGISTRY_HAS_REQUIRED_IDENTITY=REUSE_REGISTRY"
echo "IF_PROJECT_REGISTRY_IS_PARTIAL=EXTEND_ONLY_MISSING_IDENTITY_FIELDS"
echo "IF_NO_PROJECT_IDENTITY_SOURCE_EXISTS=CLASSIFY_REGISTRY_IDENTITY_UNIT_BEFORE_ORCHESTRATOR"
echo "DO_NOT_IMPLEMENT_ORCHESTRATOR_UNTIL_BOTH_AUTHORITY_AND_IDENTITY_SOURCES_ARE_ESTABLISHED=YES"

echo
echo "=== PRESERVED BOUNDARIES ==="
echo "LOCAL_COMMIT_EFFECT_CHANGE=NO"
echo "REMOTE_PUSH_EFFECT_CHANGE=NO"
echo "APPROVAL_GATE_CHANGE=NO"
echo "GOVERNANCE_VALIDATOR_CHANGE=NO"
echo "GENERIC_CADE_EXECUTOR_CHANGE=NO"
echo "GENERIC_CADE_ROUTE_CHANGE=NO"
echo "EXECUTION_SWITCH_CHANGE=NO"
echo "ACTIVE_REPOSITORY_WRITE=NO"
echo "REMOTE_WRITE=NO"

echo
echo "NEXT_ACTION=USE_EVIDENCE_TO_CLASSIFY_ANY_PRE_ORCHESTRATOR_AUTHORITY_OR_PROJECT_IDENTITY_GAP"
