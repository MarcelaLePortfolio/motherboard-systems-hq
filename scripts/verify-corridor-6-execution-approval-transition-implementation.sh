#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="63d56ec48"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — EXECUTION APPROVAL TRANSITION IMPLEMENTATION VERIFICATION ==="
echo "MODE=EXECUTION"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"
echo "ROUTE_MOUNT_AUTHORIZED=NO"
echo

echo "=== RE-RUN TARGETED TESTS ==="
npx tsx --test db/governance-execution-approval-persistence.test.ts
node --test server/execution/compile-persisted-execution-approval.test.mjs
npx tsc --noEmit
echo

echo "=== VERIFY IMPLEMENTED CONTRACT ==="
grep -n -E \
'governance_execution_approvals|approval_id TEXT PRIMARY KEY|FOREIGN KEY \(envelope_id\)|CHECK \(status = '\''approved'\''\)|push authority requires commit authority|Execution approval already exists|Execution approval not found or ambiguous|Execution approval expired|lineage no longer matches' \
db/governance-execution-approval-persistence.ts
echo

echo "=== VERIFY COMPILER FAIL-CLOSED CONTRACT ==="
grep -n -E \
'status !== "approved"|Persisted execution approval is invalid or not approved|push_authorized === true|Persisted push approval requires commit authorization|mutation_authorized: false|shell_execution_authorized: false|autonomous_execution_authorized: false' \
server/execution/compile-persisted-execution-approval.mjs
echo

echo "=== VERIFY NO PRODUCTION REACHABILITY ==="
if git grep -n -E \
'persistGovernanceExecutionApproval|loadGovernanceExecutionApproval|compilePersistedExecutionApproval' \
-- \
server routes client/src \
':!server/execution/compile-persisted-execution-approval.mjs' \
':!server/execution/compile-persisted-execution-approval.test.mjs'
then
  echo "OBSERVATION=PRODUCTION_CALLER_CANDIDATE_FOUND"
else
  echo "OBSERVATION=NO_PRODUCTION_CALLER_FOUND"
fi
echo

echo "=== VERIFY EXCLUDED SURFACES UNCHANGED SINCE AUTHORIZED BASE ==="
git diff --exit-code 17ff7424a..HEAD -- \
  routes/cade.ts \
  server/routes/cade.ts \
  server/cade/cade-executor.ts \
  server/execution/cade-governed-commit-adapter.ts \
  server/execution/cade-governed-push-adapter.ts \
  server/index.ts
echo

echo "=== CLASSIFICATION ==="
echo "APPROVAL_PERSISTENCE_IMPLEMENTED=YES"
echo "USER_OWNED_APPROVAL_WRITE_IMPLEMENTED=YES"
echo "FAIL_CLOSED_READER_IMPLEMENTED=YES"
echo "APPROVAL_COMPILER_IMPLEMENTED=YES"
echo "TARGETED_TESTS_PASS=YES"
echo "TYPECHECK_PASS=YES"
echo "PRODUCTION_CALLER_ESTABLISHED=NO"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo "ROUTE_MOUNT_CHANGED=NO"
echo "GIT_EFFECT_CHANGED=NO"
echo "AUTHORIZED_IMPLEMENTATION_UNIT=COMPLETE_PENDING_CLOSURE_CLASSIFICATION"
echo
echo "CORRIDOR_6=SELF_IMPROVEMENT_EXECUTION_ACTIVATION_CLOSURE"
echo "CORRIDOR_6_STATUS=OPEN_POST_IMPLEMENTATION_VERIFICATION"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_ACTION=CLASSIFY_APPROVAL_TRANSITION_UNIT_CLOSED_AND_REASSESS_MINIMUM_PRODUCTION_REACHABILITY"
echo

echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
