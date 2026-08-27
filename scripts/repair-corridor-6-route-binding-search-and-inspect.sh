#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="de08742ab"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — ROUTE BINDING SEARCH REPAIR / INSPECTION ==="
echo "MODE=EXECUTION"
echo "PURPOSE=REPAIR_FAILED_GREPPER_AND_ESTABLISH_EXACT_ROUTE_IMPLEMENTATION_BINDINGS"
echo "PRODUCTION_CHANGE=NONE"
echo

echo "=== PRIOR OBSERVATION ==="
echo "PRIOR_ROUTE_BINDING_SEARCH_RESULT=INVALID_GREP_PATTERN_EMPTY_SUBEXPRESSION"
echo "PRIOR_SEARCH_EVIDENCE_USABLE=NO"
echo "IMPLEMENTATION_SHOULD_NOT_PROCEED_FROM_FAILED_SEARCH=YES"
echo

echo "=== EXISTING ROUTE FACTORY PATTERNS ==="
grep -RniE \
  'express\.Router|Router\(\)|create[A-Za-z0-9_]*Router|router\.post|router\.get' \
  server/routes \
  --include='*.ts' \
  --include='*.mjs' \
  --include='*.js' \
  | head -n 300 || true
echo

echo "=== EXECUTION BINDING EXPORTS ==="
grep -RniE \
  'executeProductionExecutionEntryPoint|evaluateExecutionApproval|compilePersistedExecutionApproval|loadGovernanceExecutionScope|loadGovernanceExecutionApproval' \
  server db \
  --include='*.ts' \
  --include='*.mjs' \
  --include='*.js' \
  --exclude='*.test.ts' \
  --exclude='*.test.mjs' \
  --exclude='*.spec.ts' \
  --exclude='*.spec.mjs' \
  | head -n 300 || true
echo

echo "=== GOVERNANCE VALIDATION SOURCE SEARCH ==="
grep -RniE \
  'governance.*ok|validation.*ok|validate.*governance|governanceValidation|governance_validation' \
  server db \
  --include='*.ts' \
  --include='*.mjs' \
  --include='*.js' \
  --exclude='*.test.ts' \
  --exclude='*.test.mjs' \
  | head -n 300 || true
echo

echo "=== ROUTE TEST DEPENDENCY-INJECTION PATTERNS ==="
grep -RniE \
  'create.*Router.*\(|dependencies|deps|Database|:memory:|supertest|request\(' \
  server/routes \
  --include='*.test.ts' \
  --include='*.test.mjs' \
  --include='*.spec.ts' \
  --include='*.spec.mjs' \
  | head -n 300 || true
echo

echo "=== SERVER MOUNT CHECK ==="
grep -nE \
  'matildaCanonicalPackageRouter|createGovernanceDelegationRouter|execution.*Router|app\.use|router' \
  server/index.ts \
  | head -n 220 || true
echo

echo "=== SOURCE SNAPSHOTS ==="
for file in \
  server/routes/matilda-canonical-package-route.ts \
  server/routes/governance-delegation-route.ts \
  server/execution/production-execution-entry-point.ts \
  server/execution/execution-approval-gate.mjs \
  server/execution/compile-persisted-execution-approval.mjs \
  db/governance-execution-approval-persistence.ts \
  db/governance-execution-scope-persistence.ts
do
  if [[ -f "$file" ]]; then
    echo
    echo "--- $file ---"
    sed -n '1,420p' "$file"
  fi
done

echo
echo "=== BOUNDARY ==="
echo "ROUTE_IMPLEMENTATION_CHANGED=NO"
echo "ROUTE_MOUNT_CHANGED=NO"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo "GIT_EFFECT_CHANGED=NO"
echo "GENERIC_CADE_CHANGED=NO"
echo "SCHEDULER_OR_AUTONOMY_CHANGED=NO"
echo

echo "=== RESULT ==="
echo "FAILED_ROUTE_BINDING_SEARCH_REPAIRED=YES"
echo "CORRIDOR_6_STATUS=UNMOUNTED_DEDICATED_EXECUTION_ROUTE_BINDINGS_UNDER_EXACT_INSPECTION"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_ACTION=CLASSIFY_EXACT_ROUTE_FACTORY_DATABASE_GOVERNANCE_AND_ENVELOPE_BINDINGS_FROM_OUTPUT_BEFORE_IMPLEMENTATION"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
