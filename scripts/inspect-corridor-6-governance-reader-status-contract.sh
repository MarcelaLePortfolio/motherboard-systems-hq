#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="b4ec1d9f5"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — GOVERNANCE READER STATUS CONTRACT INSPECTION ==="
echo "MODE=EXECUTION"
echo "AUTHORIZED_IMPLEMENTATION_UNIT=GOVERNANCE_READ_ONLY_READERS_AND_TARGETED_TESTS"
echo "PRODUCTION_CHANGE=NONE"
echo

echo "=== EXACT LIFECYCLE ENFORCEMENT SEMANTICS ==="
sed -n '1,260p' db/governance-lifecycle-enforcement.ts
echo

echo "=== EXACT EXISTING READ-REPOSITORY SEMANTICS ==="
sed -n '1,260p' db/mission-read-repository.ts
echo

echo "=== GOVERNANCE TABLE DEFINITIONS ==="
sed -n '218,330p' db/governance-runtime.ts
echo

echo "=== GOVERNANCE ARTIFACT TYPES ==="
sed -n '40,218p' db/governance-runtime.ts
echo

echo "=== STATUS HELPERS / ACCEPTED VALUES ==="
grep -RniE \
  'isDelegationAuthorized|isValidationPassed|isEnvelopeGateOpen|AUTHORIZED|VALIDATION_PASSED|gate_status.*OPEN|gate_status.*PASSED' \
  db/governance-lifecycle-enforcement.ts \
  db/mission-read-model-assembler.ts \
  db/governance-runtime.ts \
  | head -n 260 || true
echo

echo "=== DATABASE OWNERSHIP / INJECTION CHECK ==="
sed -n '1,45p' db/governance-runtime.ts
echo
grep -RniE \
  'new Database|better-sqlite3|export.*sqlite|set.*Database|Database.*=' \
  db/governance-runtime.ts \
  db/governance-*.ts \
  --exclude='*.test.ts' \
  | head -n 260 || true
echo

echo "=== AUTHORIZED IMPLEMENTATION DECISION QUESTIONS ==="
echo "Q1_DELEGATION_SUCCESS_STATUS=RESOLVE_FROM_LIFECYCLE_ENFORCEMENT_OUTPUT"
echo "Q2_VALIDATION_SUCCESS_STATUS=RESOLVE_FROM_LIFECYCLE_ENFORCEMENT_OUTPUT"
echo "Q3_GATE_SUCCESS_STATUS=RESOLVE_FROM_LIFECYCLE_ENFORCEMENT_OUTPUT"
echo "Q4_EXISTING_STATUS_HELPERS_REUSABLE=RESOLVE_FROM_EXPORT_VISIBILITY"
echo "Q5_READER_SHOULD_USE_INJECTED_DATABASE=YES_IF_NO_SAFE_SHARED_READ_API_EXISTS"
echo

echo "=== PRESERVED BOUNDARY ==="
echo "NEW_WRITE_PATH_CREATED=NO"
echo "NEW_AUTHORITY_CREATED=NO"
echo "ROUTE_IMPLEMENTATION_CHANGED=NO"
echo "ROUTE_MOUNT_CHANGED=NO"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo "GIT_EFFECT_CHANGED=NO"
echo "GENERIC_CADE_CHANGED=NO"
echo "GENERIC_SHELL_OR_MUTATION_AUTHORITY_CHANGED=NO"
echo "SCHEDULER_OR_AUTONOMY_CHANGED=NO"
echo

echo "CORRIDOR_6_STATUS=GOVERNANCE_READ_UNIT_IMPLEMENTATION_IN_PROGRESS"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_ACTION=IMPLEMENT_AUTHORIZED_FAIL_CLOSED_READERS_USING_EXACT_VERIFIED_STATUS_SEMANTICS"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
