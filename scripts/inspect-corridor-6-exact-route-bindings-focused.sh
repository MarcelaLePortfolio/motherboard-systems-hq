#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="38a3432a7"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — FOCUSED DEDICATED ROUTE BINDING INSPECTION ==="
echo "MODE=EXECUTION"
echo "ROUTE_IMPLEMENTATION_AUTHORIZED=YES"
echo "ROUTE_MOUNT_AUTHORIZED=NO"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"
echo

echo "=== Q1 — EXACT ENVELOPE READERS ==="
git grep -n -E \
'SELECT .*governance_envelopes|FROM governance_envelopes|readGovernanceEnvelope|loadGovernanceEnvelope|governanceEnvelope' \
-- db \
':!**/*.test.ts' \
|| true
echo

echo "=== MISSION READ GOVERNANCE ENVELOPE BLOCK ==="
grep -n -B20 -A70 'governance_envelopes' db/mission-read-repository.ts || true
echo

echo "=== GOVERNANCE RUNTIME ENVELOPE TYPE / CREATE SHAPE ==="
grep -n -B20 -A120 -E \
'CreateGovernanceEnvelopeInput|CreatedGovernanceEnvelope|createGovernanceEnvelope' \
db/governance-runtime.ts || true
echo

echo "=== Q2 / Q3 — EXECUTION APPROVAL GATE EXPORT AND INPUT SHAPE ==="
grep -n -B60 -A180 \
'export function evaluateExecutionApproval' \
server/execution/execution-approval-gate.mjs
echo

echo "=== GATE NORMALIZATION DEPENDENCIES ==="
grep -n -B20 -A100 -E \
'function normalizeApproval|function normalize.*Envelope|delegation_authorization|governance' \
server/execution/execution-approval-gate.mjs | head -320 || true
echo

echo "=== BOUNDED ENTRY POINT CALL CONTRACT ==="
sed -n '1,240p' server/execution/production-execution-entry-point.ts
echo

echo "=== Q4 — ROUTE DEPENDENCY-INJECTION PATTERNS ==="
grep -n -B20 -A120 -E \
'RouteOptions|create.*Router|handle.*RouteRequest' \
server/routes/governance-delegation-route.ts | head -320 || true
echo

echo "=== Q5 — APPROVAL READER CURRENT DB CONTRACT ==="
grep -n -B20 -A150 \
'export function loadGovernanceExecutionApproval' \
db/governance-execution-approval-persistence.ts
echo

echo "=== CURRENT GOVERNANCE DATABASE OWNER ==="
grep -n -B8 -A18 \
'const sqlite = new Database' \
db/governance-runtime.ts || true
echo

echo "=== CLASSIFICATION STOP ==="
echo "NO_ROUTE_FILE_CREATED=YES"
echo "NO_SERVER_MOUNT_CHANGED=YES"
echo "NO_PRODUCTION_REACHABILITY_CHANGED=YES"
echo "NO_REAL_GIT_EFFECT_PERFORMED=YES"
echo "NEXT_ACTION=CLASSIFY_EXACT_BINDINGS_AND_MINIMUM_READER_ADDITION_FROM_FOCUSED_OUTPUT"
echo
echo "HEAD=$(git rev-parse HEAD)"
echo "BRANCH=$(git branch --show-current)"
git status --short
