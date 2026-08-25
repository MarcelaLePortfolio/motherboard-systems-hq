#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== AUTHORITATIVE MISSION PACKAGE HANDOFF — DOWNSTREAM LINEAGE REQUIREMENT ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFIED PRIOR DETERMINATIONS ==="
echo "VALIDATION_ONLY_RECONCILIATION=FALSIFIED_AS_ISOLATED_SOLUTION"
echo "SMALLEST_COHERENT_DOWNSTREAM_LINEAGE_CANDIDATE=VALIDATION_PLUS_ENVELOPE_GATE_PLUS_ENVELOPE"
echo "OPERATIONAL_INTAKE_INCLUDED=NO"
echo "ASSIGNMENT_INCLUDED=NO"
echo "ROUTING_INCLUDED=NO"
echo "EXECUTION_INCLUDED=NO"
echo "HISTORICAL_CORRIDOR_SMOKE_MUTATION_AUTHORIZED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== ACTIVE HANDOFF EVIDENCE ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'Authoritative Mission Package|Mission Package Handoff|Package Handoff|Governance Runtime Activation|Production Delegation Package Root Reconciliation|Canonical Package.*Delegation|Delegation.*Canonical Package' \
  docs/governance docs/checkpoints \
  2>/dev/null | head -n 3200

echo
echo "=== HANDOFF SUCCESS-CRITERIA EVIDENCE ==="
rg -n -C 14 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'success criteria|completion criteria|handoff.*complete|Delegation.*complete|delegation.*authorized|operational package|operational authority|Validation.*required|Envelope Gate.*required|Envelope.*required' \
  docs/governance \
  2>/dev/null | head -n 3200

echo
echo "=== CURRENT CANONICAL PACKAGE TO DELEGATION PATH ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'createGovernanceDelegation|consumeProductionDelegation|invokeProductionDelegation|matilda_canonical_packages|authorization_state' \
  db server routes \
  2>/dev/null | head -n 3000

echo
echo "=== DOWNSTREAM ENTRY-POINT RELATIONSHIP ==="
rg -n -C 14 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'consumeProductionValidationEntryPoint|consumeProductionEnvelopeGateEntryPoint|consumeProductionEnvelopeEntryPoint|invokeProductionValidationEntryPoint|invokeProductionEnvelopeGateEntryPoint|invokeProductionEnvelopeEntryPoint' \
  server \
  2>/dev/null | head -n 3200

echo
echo "=== ACTIVE-HANDOFF DEPENDENCY FALSIFICATION ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'Delegation.*Validation|Validation.*Delegation|handoff.*Validation|Validation.*handoff|after Delegation|following Delegation|prerequisite for Governance Validation|Governance Validation consumes Delegation' \
  docs/governance server db \
  2>/dev/null | head -n 3000

echo
echo "=== CURRENT LIVE ARTIFACT COUNTS ==="
sqlite3 -header -column db/main.db "
SELECT 'canonical_packages' AS artifact, COUNT(*) AS records
FROM matilda_canonical_packages
UNION ALL
SELECT 'delegations', COUNT(*) FROM governance_delegations
UNION ALL
SELECT 'validations', COUNT(*) FROM governance_validation_results
UNION ALL
SELECT 'gates', COUNT(*) FROM governance_envelope_gates
UNION ALL
SELECT 'envelopes', COUNT(*) FROM governance_envelopes;
"

echo
echo "=== CANONICAL PACKAGE / DELEGATION LINEAGE ==="
sqlite3 -header -column db/main.db "
SELECT
  cp.package_id,
  cp.package_version,
  cp.status,
  d.delegation_id,
  d.authorization_state
FROM matilda_canonical_packages cp
LEFT JOIN governance_delegations d
  ON d.package_id = cp.package_id
 AND d.package_version = cp.package_version
ORDER BY cp.created_at;
"

echo
echo "=== DATABASE INTEGRITY ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== SCOPE DETERMINATION QUESTIONS ==="
echo "QUESTION_1=IS_CANONICAL_PACKAGE_TO_AUTHORIZED_DELEGATION_THE_REQUIRED_OUTPUT_OF_THE_ACTIVE_HANDOFF_PHASE"
echo "QUESTION_2=DOES_ACTIVE_HANDOFF_COMPLETION_REQUIRE_VALIDATION_GATE_OR_ENVELOPE"
echo "QUESTION_3=WOULD_DEFERRING_DOWNSTREAM_ROOT_RECONCILIATION_BLOCK_ACTIVE_HANDOFF_SUCCESS_CRITERIA"
echo "QUESTION_4=IS_VALIDATION_GATE_ENVELOPE_RECONCILIATION_A_SUCCESSOR_PIPELINE_CORRIDOR"

echo
echo "=== CLASSIFICATION ==="
echo "VERIFIED_OUTCOME=FULL_DOWNSTREAM_COHERENT_LINEAGE_CANDIDATE_IS_VALIDATION_PLUS_ENVELOPE_GATE_PLUS_ENVELOPE"
echo "CURRENT_SCOPE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF_REQUIREMENT_CLASSIFICATION"
echo "DO_NOT_ASSUME_FULL_DOWNSTREAM_CANDIDATE_IS_ACTIVE_BLOCKER=YES"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=DETERMINE_FROM_AUTHORITATIVE_HANDOFF_SUCCESS_CRITERIA_WHETHER_DOWNSTREAM_RECONCILIATION_IS_ACTIVE_PREREQUISITE_OR_SEPARATELY_DEFERRED_SUCCESSOR_CORRIDOR"
