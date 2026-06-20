
CREATE TABLE IF NOT EXISTS governance_packages (

  package_id TEXT NOT NULL,

  package_version INTEGER NOT NULL,

  requested_outcome TEXT,

  scope TEXT,

  containment TEXT,

  constraints TEXT,

  success_criteria TEXT,

  context TEXT,

  style_presentation_intent TEXT,

  exclusions TEXT,

  created_at TEXT NOT NULL,

  PRIMARY KEY (package_id, package_version)

);

CREATE TABLE IF NOT EXISTS governance_delegations (

  delegation_id TEXT PRIMARY KEY,

  package_id TEXT NOT NULL,

  package_version INTEGER NOT NULL,

  authorization_state TEXT NOT NULL,

  authorization_timestamp TEXT NOT NULL,

  delegated_by TEXT NOT NULL,

  created_at TEXT NOT NULL,

  FOREIGN KEY (package_id, package_version)

    REFERENCES governance_packages(package_id, package_version)

);

CREATE TABLE IF NOT EXISTS governance_validation_results (

  validation_result_id TEXT PRIMARY KEY,

  package_id TEXT NOT NULL,

  package_version INTEGER NOT NULL,

  delegation_id TEXT NOT NULL,

  validation_status TEXT NOT NULL,

  governance_findings TEXT,

  operational_requirements TEXT,

  capability_requirements TEXT,

  escalations TEXT,

  validation_timestamp TEXT NOT NULL,

  created_at TEXT NOT NULL,

  FOREIGN KEY (package_id, package_version)

    REFERENCES governance_packages(package_id, package_version),

  FOREIGN KEY (delegation_id)

    REFERENCES governance_delegations(delegation_id)

);

CREATE TABLE IF NOT EXISTS governance_envelope_gates (

  envelope_gate_id TEXT PRIMARY KEY,

  package_id TEXT NOT NULL,

  package_version INTEGER NOT NULL,

  delegation_id TEXT NOT NULL,

  validation_result_id TEXT NOT NULL,

  gate_status TEXT NOT NULL,

  gate_reason TEXT,

  gate_decision_timestamp TEXT NOT NULL,

  created_at TEXT NOT NULL,

  FOREIGN KEY (package_id, package_version)

    REFERENCES governance_packages(package_id, package_version),

  FOREIGN KEY (delegation_id)

    REFERENCES governance_delegations(delegation_id),

  FOREIGN KEY (validation_result_id)

    REFERENCES governance_validation_results(validation_result_id)

);

CREATE TABLE IF NOT EXISTS governance_envelopes (

  envelope_id TEXT PRIMARY KEY,

  package_id TEXT NOT NULL,

  package_version INTEGER NOT NULL,

  delegation_id TEXT NOT NULL,

  validation_result_id TEXT NOT NULL,

  envelope_gate_id TEXT NOT NULL,

  validation_status TEXT NOT NULL,

  required_capabilities TEXT,

  operational_corridor TEXT,

  lifecycle_state TEXT NOT NULL,

  created_at TEXT NOT NULL,

  FOREIGN KEY (package_id, package_version)

    REFERENCES governance_packages(package_id, package_version),

  FOREIGN KEY (delegation_id)

    REFERENCES governance_delegations(delegation_id),

  FOREIGN KEY (validation_result_id)

    REFERENCES governance_validation_results(validation_result_id),

  FOREIGN KEY (envelope_gate_id)

    REFERENCES governance_envelope_gates(envelope_gate_id)

);

