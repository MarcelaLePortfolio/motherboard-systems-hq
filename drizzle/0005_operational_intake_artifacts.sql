
CREATE TABLE IF NOT EXISTS operational_intake_records (

  intake_id TEXT PRIMARY KEY,

  envelope_id TEXT NOT NULL,

  package_id TEXT NOT NULL,

  package_version INTEGER NOT NULL,

  delegation_id TEXT NOT NULL,

  validation_result_id TEXT NOT NULL,

  envelope_gate_id TEXT NOT NULL,

  lifecycle_state_at_intake TEXT NOT NULL,

  assigned_department TEXT NOT NULL,

  required_capabilities_snapshot TEXT,

  intake_status TEXT NOT NULL,

  intake_created_at TEXT NOT NULL,

  intake_updated_at TEXT NOT NULL,

  governance_authority_preserved INTEGER NOT NULL,

  lifecycle_authority_preserved INTEGER NOT NULL,

  assignment_authority_preserved INTEGER NOT NULL,

  routing_authorized INTEGER NOT NULL,

  scheduler_authorized INTEGER NOT NULL,

  worker_claim_authorized INTEGER NOT NULL,

  execution_authorized INTEGER NOT NULL,

  FOREIGN KEY (envelope_id)

    REFERENCES governance_envelopes(envelope_id),

  FOREIGN KEY (package_id, package_version)

    REFERENCES governance_packages(package_id, package_version),

  FOREIGN KEY (delegation_id)

    REFERENCES governance_delegations(delegation_id),

  FOREIGN KEY (validation_result_id)

    REFERENCES governance_validation_results(validation_result_id),

  FOREIGN KEY (envelope_gate_id)

    REFERENCES governance_envelope_gates(envelope_gate_id)

);

CREATE UNIQUE INDEX IF NOT EXISTS idx_operational_intake_records_envelope_id

  ON operational_intake_records(envelope_id);

