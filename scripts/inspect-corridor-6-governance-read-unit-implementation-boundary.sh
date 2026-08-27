#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="28bb23ea8"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — GOVERNANCE READ UNIT IMPLEMENTATION BOUNDARY ==="
echo "MODE=EXECUTION"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "PRODUCTION_CHANGE=NONE"
echo

echo "=== AUTHORIZED UNIT ==="
echo "UNIT_1=FAIL_CLOSED_EXACT_DELEGATION_READER"
echo "UNIT_2=FAIL_CLOSED_EXACT_VALIDATION_RESULT_READER"
echo "UNIT_3=FAIL_CLOSED_EXACT_ENVELOPE_GATE_OR_LINEAGE_READER"
echo "UNIT_4=EXACT_PACKAGE_VERSION_DELEGATION_VALIDATION_CORRELATION"
echo "UNIT_5=TARGETED_READ_ONLY_TESTS"
echo

echo "=== EXACT GOVERNANCE RUNTIME STRUCTURE ==="
sed -n '1,1120p' db/governance-runtime.ts
echo

echo "=== CURRENT GOVERNANCE RUNTIME TEST COVERAGE ==="
for file in db/governance-runtime.test.ts db/governance-runtime*.test.ts
do
  if [[ -f "$file" ]]; then
    echo "--- $file ---"
    sed -n '1,520p' "$file"
    echo
  fi
done

echo "=== TABLE / TYPE / EXPORT LOCATIONS ==="
grep -nE \
  'type .*Governance|interface .*Governance|governance_delegations|governance_validation_results|governance_envelope_gates|governance_envelopes|export function' \
  db/governance-runtime.ts \
  | head -n 520 || true
echo

echo "=== STATUS VALUES USED BY CURRENT GOVERNANCE WRITERS / TESTS ==="
grep -RniE \
  'authorization_state|validation_status|gate_status' \
  db server \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  --include='*.test.ts' --include='*.test.mjs' \
  | head -n 520 || true
echo

echo "=== IMPLEMENTATION RULES ==="
echo "MUTATE_EXISTING_GOVERNANCE_PERSISTENCE_OWNER_ONLY=YES"
echo "READER_ONLY_NO_NEW_WRITES=YES"
echo "MISSING_OR_AMBIGUOUS_ROW_FAIL_CLOSED=YES"
echo "PACKAGE_VERSION_LINEAGE_EXACT=YES"
echo "DELEGATION_VALIDATION_GATE_CORRELATION_EXACT=YES"
echo "NO_AUTHORITY_SYNTHESIS=YES"
echo "NO_NEW_DATABASE_OWNER=YES"
echo "NO_ROUTE_IMPLEMENTATION_IN_THIS_UNIT=YES"
echo "NO_ROUTE_MOUNT=YES"
echo "NO_PRODUCTION_REACHABILITY=YES"
echo "NO_GIT_EFFECT_CHANGES=YES"
echo

echo "=== RESULT ==="
echo "IMPLEMENTATION_BOUNDARY_INSPECTED=YES"
echo "NEXT_ACTION=IMPLEMENT_AUTHORIZED_READ_ONLY_GOVERNANCE_READERS_AND_TARGETED_TESTS_USING_EXACT_REPOSITORY_STATUS_SEMANTICS"
echo "CORRIDOR_6_STATUS=GOVERNANCE_READ_UNIT_IMPLEMENTATION_IN_PROGRESS"
echo "PHASE_1_STATUS=ACTIVE"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
