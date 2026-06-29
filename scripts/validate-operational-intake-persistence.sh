
#!/usr/bin/env bash

set -euo pipefail

DB_FILE="$(mktemp)"

trap 'rm -f "$DB_FILE"' EXIT

sqlite3 "$DB_FILE" <<'SQL'

PRAGMA foreign_keys = ON;

.read drizzle/0004_governance_lifecycle_artifacts.sql

.read drizzle/0005_operational_intake_artifacts.sql

INSERT INTO governance_packages (

  package_id,

  package_version,

  requested_outcome,

  scope,

  containment,

  constraints,

  success_criteria,

  created_at

) VALUES (

  'pkg-intake-test',

  1,

  'Validate operational intake persistence',

  'Schema-only validation',

  'No runtime behavior',

  'Authority separation preserved',

  'Operational intake table accepts valid lineage',

  '2026-06-29T00:00:00.000Z'

);

INSERT INTO governance_delegations (

  delegation_id,

  package_id,

  package_version,

  authorization_state,

  authorization_timestamp,

  delegated_by,

  created_at

) VALUES (

  'del-intake-test',

  'pkg-intake-test',

  1,

  'AUTHORIZED',

  '2026-06-29T00:00:00.000Z',

  'marcela',

  '2026-06-29T00:00:00.000Z'

);

INSERT INTO governance_validation_results (

  validation_result_id,

  package_id,

  package_version,

  delegation_id,

  validation_status,

  validation_timestamp,

  created_at

) VALUES (

  'val-intake-test',

  'pkg-intake-test',

  1,

  'del-intake-test',

  'VALIDATION_PASSED',

  '2026-06-29T00:00:00.000Z',

  '2026-06-29T00:00:00.000Z'

);

INSERT INTO governance_envelope_gates (

  envelope_gate_id,

  package_id,

  package_version,

  delegation_id,

  validation_result_id,

  gate_status,

  gate_decision_timestamp,

  created_at

) VALUES (

  'gate-intake-test',

  'pkg-intake-test',

  1,

  'del-intake-test',

  'val-intake-test',

  'OPEN',

  '2026-06-29T00:00:00.000Z',

  '2026-06-29T00:00:00.000Z'

);

INSERT INTO governance_envelopes (

  envelope_id,

  package_id,

  package_version,

  delegation_id,

  validation_result_id,

  envelope_gate_id,

  validation_status,

  required_capabilities,

  operational_corridor,

  lifecycle_state,

  created_at

) VALUES (

  'env-intake-test',

  'pkg-intake-test',

  1,

  'del-intake-test',

  'val-intake-test',

  'gate-intake-test',

  'VALIDATION_PASSED',

  '["engineering"]',

  'Operational Intake',

  'ASSIGNED',

  '2026-06-29T00:00:00.000Z'

);

INSERT INTO operational_intake_records (

  intake_id,

  envelope_id,

  package_id,

  package_version,

  delegation_id,

  validation_result_id,

  envelope_gate_id,

  lifecycle_state_at_intake,

  assigned_department,

  required_capabilities_snapshot,

  intake_status,

  intake_created_at,

  intake_updated_at,

  governance_authority_preserved,

  lifecycle_authority_preserved,

  assignment_authority_preserved,

  routing_authorized,

  scheduler_authorized,

  worker_claim_authorized,

  execution_authorized

) VALUES (

  'intake-test-1',

  'env-intake-test',

  'pkg-intake-test',

  1,

  'del-intake-test',

  'val-intake-test',

  'gate-intake-test',

  'ASSIGNED',

  'engineering',

  '["engineering"]',

  'RECORDED',

  '2026-06-29T00:00:00.000Z',

  '2026-06-29T00:00:00.000Z',

  1,

  1,

  1,

  0,

  0,

  0,

  0

);

SELECT 'PASS operational intake persistence schema validation';

SQL

