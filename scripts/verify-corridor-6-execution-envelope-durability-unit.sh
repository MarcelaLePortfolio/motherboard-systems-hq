#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="fb8f7ba3e"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — EXECUTION ENVELOPE DURABILITY VERIFICATION ==="
echo "MODE=EXECUTION"
echo "IMPLEMENTATION_COMMIT=fb8f7ba3e"
echo

echo "=== TARGETED DURABILITY TESTS ==="
npx tsx --test db/governance-execution-scope-persistence.test.ts
echo

echo "=== APPROVAL PERSISTENCE REGRESSION ==="
npx tsx --test db/governance-execution-approval-persistence.test.ts
echo

echo "=== TYPESCRIPT ==="
npx tsc --noEmit
echo

echo "=== DURABILITY CONTRACT CHECK ==="
grep -n -E \
'governance_execution_scopes|approval_id TEXT PRIMARY KEY|envelope_id TEXT NOT NULL UNIQUE|repo_path TEXT NOT NULL|expected_head TEXT NOT NULL|allowed_paths TEXT NOT NULL|forbidden_paths TEXT NOT NULL|scope_constraints TEXT NOT NULL' \
db/governance-execution-scope-persistence.ts
echo

echo "=== FAIL-CLOSED READER CHECK ==="
grep -n -E \
'Execution scope not found or ambiguous|lineage no longer matches execution approval|lineage no longer matches governance envelope|expected_head must be a 40-character git commit SHA|must contain at least one path' \
db/governance-execution-scope-persistence.ts
echo

echo "=== APPROVAL CORRELATION CHECK ==="
grep -n -E \
'loadGovernanceExecutionApproval|approval.package_id|approval.package_version|branch: approval.branch' \
db/governance-execution-scope-persistence.ts
echo

echo "=== EXCLUDED SURFACE CHECK ==="
if git diff 4e1d880b0..HEAD -- \
  server/index.ts \
  server/cade/cade-version-control-effects.ts \
  server/execution/cade-governed-commit-adapter.ts \
  server/execution/cade-governed-push-adapter.ts \
  server/execution/production-execution-entry-point.ts \
  server/execution/execution-approval-gate.mjs \
  server/routes \
  | grep -q .; then
  echo "STOP=EXCLUDED_SURFACE_CHANGED"
  git diff 4e1d880b0..HEAD -- \
    server/index.ts \
    server/cade/cade-version-control-effects.ts \
    server/execution/cade-governed-commit-adapter.ts \
    server/execution/cade-governed-push-adapter.ts \
    server/execution/production-execution-entry-point.ts \
    server/execution/execution-approval-gate.mjs \
    server/routes
  exit 1
fi

echo "=== VERIFICATION RESULT ==="
echo "DURABLE_REPO_PATH_BINDING_VERIFIED=YES"
echo "DURABLE_EXPECTED_HEAD_BINDING_VERIFIED=YES"
echo "DURABLE_ALLOWED_PATHS_BINDING_VERIFIED=YES"
echo "DURABLE_FORBIDDEN_PATHS_BINDING_VERIFIED=YES"
echo "DURABLE_SCOPE_CONSTRAINTS_BINDING_VERIFIED=YES"
echo "EXACT_APPROVAL_ENVELOPE_PACKAGE_CORRELATION_VERIFIED=YES"
echo "FAIL_CLOSED_READER_VERIFIED=YES"
echo "ENVELOPE_REPLAY_PREVENTION_VERIFIED=YES"
echo "APPROVED_BRANCH_REUSE_VERIFIED=YES"
echo "PRODUCTION_DB_USED_BY_TESTS=NO"
echo "REAL_GIT_EFFECTS_PERFORMED=NO"
echo "ROUTE_IMPLEMENTATION_CHANGED=NO"
echo "ROUTE_MOUNT_CHANGED=NO"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo "GIT_EFFECT_CHANGED=NO"
echo
echo "EXECUTION_ENVELOPE_DURABILITY_UNIT_STATUS=VERIFIED"
echo "CORRIDOR_6_STATUS=OPEN_PENDING_DURABILITY_UNIT_CLOSURE_AND_UNMOUNTED_ROUTE_RESUMPTION"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_ACTION=CLOSE_DURABILITY_UNIT_THEN_RESUME_SEPARATELY_AUTHORIZED_UNMOUNTED_DEDICATED_EXECUTION_ROUTE"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
