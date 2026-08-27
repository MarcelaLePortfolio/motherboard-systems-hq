#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="2770fb469"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — RESUME UNMOUNTED EXECUTION ROUTE IMPLEMENTATION ==="
echo "MODE=EXECUTION"
echo "PRODUCTION_CHANGE=NONE"
echo

echo "=== VERIFIED PRECONDITIONS ==="
echo "GOVERNANCE_READ_UNIT_STATUS=CLOSED"
echo "GOVERNANCE_READ_UNIT_VERIFICATION_COMMIT=2770fb469"
echo "UNMOUNTED_ROUTE_IMPLEMENTATION_AUTHORIZATION=VALID"
echo "SERVER_ROUTE_MOUNT_AUTHORIZED=NO"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"
echo

echo "=== ROUTE BINDING SOURCES ==="
sed -n '1,320p' db/governance-execution-approval-persistence.ts
sed -n '1,320p' db/governance-execution-scope-persistence.ts
sed -n '1,320p' db/governance-execution-read-repository.ts
sed -n '1,320p' server/execution/compile-persisted-execution-approval.mjs
sed -n '1,360p' server/execution/production-execution-entry-point.ts
echo

echo "=== EXISTING ROUTE SHAPES / TEST PATTERNS ==="
for file in \
  server/routes/governance-delegation-route.ts \
  server/routes/governance-delegation-route.test.ts \
  server/routes/governance-validation-route.ts \
  server/routes/governance-validation-route.test.ts \
  server/routes/governance-envelope-route.ts \
  server/routes/governance-envelope-route.test.ts
do
  if [[ -f "$file" ]]; then
    echo "--- $file ---"
    sed -n '1,280p' "$file"
  fi
done
echo

echo "=== IMPLEMENTATION BOUNDARY ==="
echo "ROUTE_ROLE=READ_VALIDATE_RECONSTRUCT_COMPILE_BIND_AND_INVOKE"
echo "CLIENT_AUTHORITY_FIELDS=PROHIBITED"
echo "ROUTE_MOUNT=PROHIBITED"
echo "NEW_AUTHORITY=PROHIBITED"
echo "NEW_DELEGATION=PROHIBITED"
echo "NEW_VALIDATION=PROHIBITED"
echo "NEW_GATE=PROHIBITED"
echo "SYNTHESIZED_GOVERNANCE_OK=PROHIBITED"
echo "GENERIC_CADE_ROUTE_CHANGE=PROHIBITED"
echo "GENERIC_SHELL_OR_MUTATION_AUTHORITY=PROHIBITED"
echo "GIT_EFFECT_CHANGE=PROHIBITED"
echo "SCHEDULER_OR_AUTONOMY=PROHIBITED"
echo

echo "=== RESULT ==="
echo "UNMOUNTED_EXECUTION_ROUTE_IMPLEMENTATION_RESUMED=YES"
echo "NEXT_ACTION=IMPLEMENT_SEPARATELY_AUTHORIZED_UNMOUNTED_DEDICATED_EXECUTION_ROUTE_AND_TARGETED_TESTS"
echo "CORRIDOR_6_STATUS=UNMOUNTED_EXECUTION_ROUTE_IMPLEMENTATION_IN_PROGRESS"
echo "PHASE_1_STATUS=ACTIVE"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
