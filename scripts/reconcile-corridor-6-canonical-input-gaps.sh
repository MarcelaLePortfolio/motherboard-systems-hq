#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="32522eadb"

if [[ "$(git rev-parse HEAD)" != ${EXPECTED_HEAD}* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — CANONICAL INPUT GAP RECONCILIATION ==="
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"
echo "ROUTE_MOUNT_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo

echo "=== INPUT A — CURRENT USER EXECUTION AUTHORIZATION ==="
echo "SEARCH=CORRIDOR_2_AUTHORIZATION_OWNERSHIP_AND_DURABILITY"
git log --oneline --all -- \
  db/matilda-execution-authorization-runtime.ts \
  routes \
  server/execution |
head -80
echo

git grep -n -E \
'createExecutionAuthorization|authorization_id|authorization_result|execution_authorized|authorization_actor' \
-- \
db server routes \
':!server/authority/authority-gate.ts' \
':!**/*.test.ts' || true
echo

echo "=== INPUT B — AUTHORITATIVE EXECUTION APPROVAL TRANSITION ==="
echo "SEARCH=PRODUCTION_APPROVAL_REQUIRED_TO_APPROVED_TRANSITION"
git grep -n -E \
'buildApprovalArtifact|approval_required|status.*approved|approved_by|commit_authorized|push_authorized|version_control_authorization' \
-- \
db server routes \
':!server/execution/smoke-test-*' \
':!**/*.test.ts' || true
echo

echo "=== INPUT C — CANONICAL ENVELOPE READER ==="
echo "MISSION_READ_REPOSITORY:"
sed -n '1,180p' db/mission-read-repository.ts
echo

echo "GOVERNANCE_LIFECYCLE_PERSISTENCE:"
sed -n '1,130p' db/governance-lifecycle-persistence.ts
echo

echo "CANONICAL_PACKAGE_MISSION_PROJECTION:"
sed -n '90,190p' db/canonical-package-mission-projection.ts
echo

echo "=== EXACT ENVELOPE READABILITY CLASSIFICATION ==="
git grep -n -E \
'FROM governance_envelopes|WHERE envelope_id|WHERE package_id' \
-- \
db/mission-read-repository.ts \
db/governance-lifecycle-persistence.ts \
db/canonical-package-mission-projection.ts || true
echo

echo "=== INPUT D — EXECUTION ID ==="
echo "EXECUTION_ID_CONTRACT=CALLER_SUPPLIED"
git grep -n -E \
'executionId:[[:space:]]*string|requires execution_id' \
-- \
server/execution/production-execution-entry-point.ts \
server/execution/cade-governed-commit-adapter.ts \
server/execution/cade-governed-push-adapter.ts
echo

echo "=== RECONCILIATION QUESTIONS ==="
echo "Q1=DOES_CORRIDOR_2_AUTHORIZATION_HAVE_A_CURRENT_DURABLE_PRODUCTION_RECORD_AND_READER?"
echo "Q2=DOES_ANY_PRODUCTION_PATH_TRANSITION_EXECUTION_APPROVAL_FROM_REQUIRED_TO_APPROVED?"
echo "Q3=CAN_EXISTING_READ_INFRASTRUCTURE_RESOLVE_ONE_CANONICAL_ENVELOPE_WITH_REQUIRED_PACKAGE_LINEAGE?"
echo "Q4=CAN_THAT_READER_FAIL_CLOSED_ON_AMBIGUOUS_OR_MISMATCHED_LINEAGE?"
echo "Q5=DOES_ANY_EVIDENCE_SUPERSEDE_CALLER_SUPPLIED_EXECUTION_ID_OWNERSHIP?"
echo

echo "=== DECISION RULE ==="
echo "IF_INPUT_A_ABSENT=CLASSIFY_UPSTREAM_DURABLE_USER_AUTHORIZATION_GAP"
echo "IF_INPUT_B_ABSENT=CLASSIFY_UPSTREAM_EXECUTION_APPROVAL_TRANSITION_GAP"
echo "IF_INPUT_C_READER_EXISTS=REUSE_EXISTING_READER_OR_NARROW_EXISTING_READ_INFRASTRUCTURE"
echo "IF_INPUT_C_PERSISTED_BUT_NO_EXACT_READER=CLASSIFY_BOUNDED_READ_RESOLUTION_GAP"
echo "IF_INPUT_D_UNCHANGED=KEEP_CALLER_SUPPLIED"
echo "DO_NOT_IMPLEMENT_ROUTE_WHILE_A_OR_B_UNRESOLVED=YES"
echo "DO_NOT_INVENT_AUTHORITY_OR_APPROVAL=YES"
echo

echo "=== STOP POINT ==="
echo "CORRIDOR_6=SELF_IMPROVEMENT_EXECUTION_ACTIVATION_CLOSURE"
echo "CORRIDOR_6_STATUS=OPEN_CANONICAL_INPUT_RECONCILIATION"
echo "PHASE_1_STATUS=ACTIVE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"
echo "ROUTE_MOUNT_AUTHORIZED=NO"
echo "NO_IMPLEMENTATION_PERFORMED=YES"
echo "NEXT_DECISION=DETERMINE_WHETHER_INPUT_A_OR_INPUT_B_IS_THE_FIRST_UPSTREAM_BLOCKER"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
