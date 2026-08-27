#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="cc3a84126"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — GOVERNANCE / DELEGATION ROUTE BINDING INSPECTION ==="
echo "MODE=EXECUTION"
echo "PRODUCTION_CHANGE=NONE"
echo
echo "=== PURPOSE ==="
echo "TARGET=IDENTIFY_EXACT_EXISTING_PERSISTED_DELEGATION_AND_GOVERNANCE_VALIDATION_READ_BINDINGS_REQUIRED_BY_UNMOUNTED_EXECUTION_ROUTE"
echo "ROUTE_IMPLEMENTATION_PAUSED_FOR_THIS_INSPECTION=YES"
echo

echo "=== GOVERNANCE RUNTIME READ EXPORTS ==="
grep -nE \
  '^export function (get|load|find|read|list|validate|reconstruct|create)Governance|governance_delegations|governance_validation_results|governance_envelope_gates|governance_envelopes' \
  db/governance-runtime.ts \
  | head -n 320 || true
echo

echo "=== DELEGATION PERSISTENCE REFERENCES ==="
grep -RniE \
  'governance_delegations|delegation_id|authorization_state|delegated_by' \
  db server \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --exclude='*.spec.ts' --exclude='*.spec.mjs' \
  | head -n 360 || true
echo

echo "=== GOVERNANCE VALIDATION PERSISTENCE REFERENCES ==="
grep -RniE \
  'governance_validation_results|validation_result_id|validation_status|governance.*validation|validation.*governance' \
  db server \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --exclude='*.spec.ts' --exclude='*.spec.mjs' \
  | head -n 360 || true
echo

echo "=== GOVERNANCE ENVELOPE LINEAGE REFERENCES ==="
grep -RniE \
  'governance_envelopes|envelope_gate_id|required_capabilities|operational_corridor|lifecycle_state' \
  db server \
  --include='*.ts' --include='*.mjs' --include='*.js' \
  --exclude='*.test.ts' --exclude='*.test.mjs' \
  --exclude='*.spec.ts' --exclude='*.spec.mjs' \
  | head -n 360 || true
echo

echo "=== EXACT GOVERNANCE RUNTIME SOURCE WINDOWS ==="
grep -n -B40 -A180 'CREATE TABLE IF NOT EXISTS governance_delegations' db/governance-runtime.ts || true
echo
grep -n -B40 -A180 'CREATE TABLE IF NOT EXISTS governance_validation_results' db/governance-runtime.ts || true
echo
grep -n -B40 -A180 'export function createGovernanceDelegation' db/governance-runtime.ts || true
echo
grep -n -B40 -A180 'export function createGovernanceValidationResult' db/governance-runtime.ts || true
echo

echo "=== EXISTING ROUTE / TEST PATTERNS ==="
for file in \
  server/routes/governance-delegation-route.ts \
  server/routes/governance-delegation-route.test.ts \
  server/routes/matilda-canonical-package-route.ts \
  server/routes/matilda-canonical-package-route.test.ts
do
  if [[ -f "$file" ]]; then
    echo
    echo "--- $file ---"
    sed -n '1,420p' "$file"
  fi
done

echo
echo "=== CLASSIFICATION QUESTIONS ==="
echo "Q1_PUBLIC_EXACT_DELEGATION_READER_EXISTS=UNKNOWN_PENDING_OUTPUT"
echo "Q2_PUBLIC_EXACT_VALIDATION_READER_EXISTS=UNKNOWN_PENDING_OUTPUT"
echo "Q3_PUBLIC_EXACT_ENVELOPE_LINEAGE_READER_EXISTS=UNKNOWN_PENDING_OUTPUT"
echo "Q4_NARROW_READ_ONLY_READERS_REQUIRED=UNKNOWN_PENDING_OUTPUT"
echo "Q5_ROUTE_CAN_BIND_GOVERNANCE_OK_WITHOUT_SYNTHESIS=UNKNOWN_PENDING_OUTPUT"
echo

echo "=== PRESERVED BOUNDARY ==="
echo "ROUTE_IMPLEMENTATION_CHANGED=NO"
echo "ROUTE_MOUNT_CHANGED=NO"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo "GIT_EFFECT_CHANGED=NO"
echo "GENERIC_CADE_CHANGED=NO"
echo "GENERIC_SHELL_CHANGED=NO"
echo "GENERIC_MUTATION_CHANGED=NO"
echo "SCHEDULER_OR_AUTONOMY_CHANGED=NO"
echo
echo "CORRIDOR_6_STATUS=UNMOUNTED_ROUTE_GOVERNANCE_BINDINGS_UNDER_EXACT_INSPECTION"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_ACTION=CLASSIFY_EXISTING_OR_MINIMUM_READ_ONLY_GOVERNANCE_DELEGATION_BINDINGS_FROM_OUTPUT"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
