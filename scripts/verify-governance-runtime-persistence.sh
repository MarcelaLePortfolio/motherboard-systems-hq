#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ID="governance-runtime-smoke"
PACKAGE_VERSION=1
DELEGATION_ID="governance-runtime-smoke-delegation"
VALIDATION_ID="governance-runtime-smoke-validation"
GATE_ID="governance-runtime-smoke-gate"
ENVELOPE_ID="governance-runtime-smoke-envelope"

cleanup() {
  sqlite3 db/main.db "
    PRAGMA foreign_keys = ON;
    DELETE FROM governance_envelopes WHERE envelope_id = '$ENVELOPE_ID';
    DELETE FROM governance_envelope_gates WHERE envelope_gate_id = '$GATE_ID';
    DELETE FROM governance_validation_results WHERE validation_result_id = '$VALIDATION_ID';
    DELETE FROM governance_delegations WHERE delegation_id = '$DELEGATION_ID';
    DELETE FROM governance_packages
      WHERE package_id = '$PACKAGE_ID'
        AND package_version = $PACKAGE_VERSION;
  "
}

trap cleanup EXIT
cleanup

npx ts-node \
  --compiler-options '{"module":"CommonJS","moduleResolution":"Node","esModuleInterop":true}' <<'TS'
const runtime = require("./db/governance-runtime");
const timestamp = new Date().toISOString();

runtime.createGovernancePackage({
  package_id: "governance-runtime-smoke",
  package_version: 1,
  project_id: "hq",
  conversation_id: "conversation-governance-bridge",
  requested_outcome: "Verify governance runtime persistence",
  scope: "Smoke test",
  containment: "Local verification",
  constraints: "None",
  success_criteria: "Complete governance chain persists",
});

runtime.createGovernanceDelegation({
  delegation_id: "governance-runtime-smoke-delegation",
  package_id: "governance-runtime-smoke",
  package_version: 1,
  project_id: "hq",
  conversation_id: "conversation-governance-bridge",
  authorization_state: "AUTHORIZED",
  authorization_timestamp: timestamp,
  delegated_by: "verification",
});

runtime.createGovernanceValidationResult({
  validation_result_id: "governance-runtime-smoke-validation",
  package_id: "governance-runtime-smoke",
  package_version: 1,
  project_id: "hq",
  conversation_id: "conversation-governance-bridge",
  delegation_id: "governance-runtime-smoke-delegation",
  validation_status: "VALIDATION_PASSED",
  validation_timestamp: timestamp,
});

runtime.createGovernanceEnvelopeGate({
  envelope_gate_id: "governance-runtime-smoke-gate",
  package_id: "governance-runtime-smoke",
  package_version: 1,
  project_id: "hq",
  conversation_id: "conversation-governance-bridge",
  delegation_id: "governance-runtime-smoke-delegation",
  validation_result_id: "governance-runtime-smoke-validation",
  gate_status: "PASSED",
  gate_decision_timestamp: timestamp,
});

runtime.createGovernanceEnvelope({
  envelope_id: "governance-runtime-smoke-envelope",
  package_id: "governance-runtime-smoke",
  package_version: 1,
  project_id: "hq",
  conversation_id: "conversation-governance-bridge",
  delegation_id: "governance-runtime-smoke-delegation",
  validation_result_id: "governance-runtime-smoke-validation",
  envelope_gate_id: "governance-runtime-smoke-gate",
  validation_status: "VALIDATION_PASSED",
  lifecycle_state: "ENVELOPE_CREATED",
});

console.log("Governance runtime persistence completed.");
TS

CHAIN="$(sqlite3 -separator '|' db/main.db "
SELECT
  e.envelope_id,
  e.lifecycle_state,
  g.gate_status,
  v.validation_status,
  d.authorization_state
FROM governance_envelopes e
JOIN governance_envelope_gates g
  ON e.envelope_gate_id = g.envelope_gate_id
JOIN governance_validation_results v
  ON e.validation_result_id = v.validation_result_id
JOIN governance_delegations d
  ON e.delegation_id = d.delegation_id
WHERE e.envelope_id = '$ENVELOPE_ID';
")"

EXPECTED="governance-runtime-smoke-envelope|ENVELOPE_CREATED|PASSED|VALIDATION_PASSED|AUTHORIZED"

if [ "$CHAIN" != "$EXPECTED" ]; then
  printf 'STOP: governance persistence verification failed.\n'
  printf 'Expected: %s\n' "$EXPECTED"
  printf 'Actual:   %s\n' "$CHAIN"
  exit 1
fi

printf 'Verified: %s\n' "$CHAIN"

cleanup
trap - EXIT

REMAINING="$(sqlite3 db/main.db "
SELECT
  (SELECT COUNT(*) FROM governance_packages
    WHERE package_id = '$PACKAGE_ID'
      AND package_version = $PACKAGE_VERSION)
+
  (SELECT COUNT(*) FROM governance_delegations
    WHERE delegation_id = '$DELEGATION_ID')
+
  (SELECT COUNT(*) FROM governance_validation_results
    WHERE validation_result_id = '$VALIDATION_ID')
+
  (SELECT COUNT(*) FROM governance_envelope_gates
    WHERE envelope_gate_id = '$GATE_ID')
+
  (SELECT COUNT(*) FROM governance_envelopes
    WHERE envelope_id = '$ENVELOPE_ID');
")"

if [ "$REMAINING" != "0" ]; then
  printf 'STOP: smoke-test records were not fully removed.\n'
  exit 1
fi

printf 'Governance smoke records removed successfully.\n'
