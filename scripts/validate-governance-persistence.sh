
#!/bin/bash

set -euo pipefail

DB="$(mktemp /tmp/governance-persistence-validation.XXXXXX.db)"

cleanup() {

  rm -f "$DB"

}

trap cleanup EXIT

echo "== Governance Persistence Hardening Validation =="

echo

echo "0. Prepare disposable governance database"

sqlite3 "$DB" < drizzle/0004_governance_lifecycle_artifacts.sql

echo "PASS: disposable governance schema loaded"

echo

echo "1. Verify PRAGMA foreign_keys is ON"

FK="$(sqlite3 "$DB" "PRAGMA foreign_keys = ON; PRAGMA foreign_keys;")"

echo "$FK"

if [ "$FK" != "1" ]; then

  echo "FAIL: foreign_keys is not ON"

  exit 1

fi

echo

echo "2. Invalid Delegation referencing missing Package should fail"

if sqlite3 "$DB" "PRAGMA foreign_keys = ON;

INSERT INTO governance_delegations (

  delegation_id, package_id, package_version, authorization_state, authorization_timestamp, delegated_by, created_at

) VALUES (

  'test-invalid-delegation', 'missing-package', 1, 'AUTHORIZED', datetime('now'), 'test-user', datetime('now')

);"; then

  echo "FAIL: invalid delegation was accepted"

  exit 1

else

  echo "PASS: invalid delegation was rejected"

fi

echo

echo "3. Invalid Validation Result referencing missing Delegation should fail"

if sqlite3 "$DB" "PRAGMA foreign_keys = ON;

INSERT INTO governance_validation_results (

  validation_result_id, package_id, package_version, delegation_id, validation_status,

  governance_findings, operational_requirements, capability_requirements, escalations,

  validation_timestamp, created_at

) VALUES (

  'test-invalid-validation', 'missing-package', 1, 'missing-delegation', 'PASS',

  '{}', '{}', '{}', '{}', datetime('now'), datetime('now')

);"; then

  echo "FAIL: invalid validation result was accepted"

  exit 1

else

  echo "PASS: invalid validation result was rejected"

fi

echo

echo "4. Invalid Envelope Gate referencing missing Validation Result should fail"

if sqlite3 "$DB" "PRAGMA foreign_keys = ON;

INSERT INTO governance_envelope_gates (

  envelope_gate_id, package_id, package_version, delegation_id, validation_result_id,

  gate_status, gate_reason, gate_decision_timestamp, created_at

) VALUES (

  'test-invalid-gate', 'missing-package', 1, 'missing-delegation', 'missing-validation',

  'OPEN', 'test invalid gate', datetime('now'), datetime('now')

);"; then

  echo "FAIL: invalid envelope gate was accepted"

  exit 1

else

  echo "PASS: invalid envelope gate was rejected"

fi

echo

echo "5. Invalid Envelope referencing missing Gate should fail"

if sqlite3 "$DB" "PRAGMA foreign_keys = ON;

INSERT INTO governance_envelopes (

  envelope_id, package_id, package_version, delegation_id, validation_result_id, envelope_gate_id,

  validation_status, required_capabilities, operational_corridor, lifecycle_state, created_at

) VALUES (

  'test-invalid-envelope', 'missing-package', 1, 'missing-delegation', 'missing-validation', 'missing-gate',

  'PASS', '{}', 'test', 'CREATED', datetime('now')

);"; then

  echo "FAIL: invalid envelope was accepted"

  exit 1

else

  echo "PASS: invalid envelope was rejected"

fi

echo

echo "6. Valid full artifact chain should succeed inside rollback transaction"

sqlite3 "$DB" "PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

INSERT INTO governance_packages (

  package_id, package_version, requested_outcome, scope, containment, constraints,

  success_criteria, context, style_presentation_intent, exclusions, created_at

) VALUES (

  'test-valid-package', 1, 'Validate governance persistence hardening', 'Persistence validation only',

  'Rollback test data', '{}', '{}', '{}', '{}', '{}', datetime('now')

);

INSERT INTO governance_delegations (

  delegation_id, package_id, package_version, authorization_state, authorization_timestamp, delegated_by, created_at

) VALUES (

  'test-valid-delegation', 'test-valid-package', 1, 'AUTHORIZED', datetime('now'), 'test-user', datetime('now')

);

INSERT INTO governance_validation_results (

  validation_result_id, package_id, package_version, delegation_id, validation_status,

  governance_findings, operational_requirements, capability_requirements, escalations,

  validation_timestamp, created_at

) VALUES (

  'test-valid-validation', 'test-valid-package', 1, 'test-valid-delegation', 'PASS',

  '{}', '{}', '{}', '{}', datetime('now'), datetime('now')

);

INSERT INTO governance_envelope_gates (

  envelope_gate_id, package_id, package_version, delegation_id, validation_result_id,

  gate_status, gate_reason, gate_decision_timestamp, created_at

) VALUES (

  'test-valid-gate', 'test-valid-package', 1, 'test-valid-delegation', 'test-valid-validation',

  'OPEN', 'valid reversible test chain', datetime('now'), datetime('now')

);

INSERT INTO governance_envelopes (

  envelope_id, package_id, package_version, delegation_id, validation_result_id, envelope_gate_id,

  validation_status, required_capabilities, operational_corridor, lifecycle_state, created_at

) VALUES (

  'test-valid-envelope', 'test-valid-package', 1, 'test-valid-delegation', 'test-valid-validation', 'test-valid-gate',

  'PASS', '{}', 'governance-persistence-hardening', 'CREATED', datetime('now')

);

SELECT 'valid_chain_rows_inside_transaction', count(*) FROM governance_envelopes WHERE envelope_id = 'test-valid-envelope';

ROLLBACK;

SELECT 'valid_chain_rows_after_rollback', count(*) FROM governance_envelopes WHERE envelope_id = 'test-valid-envelope';

"

echo "PASS: valid reversible chain was accepted and rolled back"

echo

echo "PASS: Governance Persistence Hardening Validation complete"

