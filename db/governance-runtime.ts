
import Database from "better-sqlite3";

export type CreateGovernancePackageInput = {

  package_id: string;

  package_version: number;

  requested_outcome: string;

  scope: string;

  containment: string;

  constraints: string;

  success_criteria: string;

  context?: string | null;

  style_presentation_intent?: string | null;

  exclusions?: string | null;

};

export type CreatedGovernancePackage = {

  package_id: string;

  package_version: number;

  created_at: string;

};

export type CreateGovernanceDelegationInput = {

  delegation_id: string;

  package_id: string;

  package_version: number;

  authorization_state: string;

  authorization_timestamp?: string | null;

  delegated_by: string;

};

export type CreatedGovernanceDelegation = {

  delegation_id: string;

  package_id: string;

  package_version: number;

  authorization_state: string;

  authorization_timestamp: string;

  delegated_by: string;

  created_at: string;

};

export type CreateGovernanceValidationResultInput = {

  validation_result_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_status: string;

  governance_findings?: string | null;

  operational_requirements?: string | null;

  capability_requirements?: string | null;

  escalations?: string | null;

  validation_timestamp?: string | null;

};

export type CreatedGovernanceValidationResult = {

  validation_result_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_status: string;

  validation_timestamp: string;

  created_at: string;

};

export type CreateGovernanceEnvelopeGateInput = {

  envelope_gate_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_result_id: string;

  gate_status: string;

  gate_reason?: string | null;

  gate_decision_timestamp?: string | null;

};

export type CreatedGovernanceEnvelopeGate = {

  envelope_gate_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_result_id: string;

  gate_status: string;

  gate_decision_timestamp: string;

  created_at: string;

};

export type CreateGovernanceEnvelopeInput = {

  envelope_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_result_id: string;

  envelope_gate_id: string;

  validation_status: string;

  required_capabilities?: string | null;

  operational_corridor?: string | null;

  lifecycle_state: string;

};

export type CreatedGovernanceEnvelope = {

  envelope_id: string;

  package_id: string;

  package_version: number;

  delegation_id: string;

  validation_result_id: string;

  envelope_gate_id: string;

  validation_status: string;

  lifecycle_state: string;

  created_at: string;

};

const sqlite = new Database("db/main.db");

sqlite.pragma("foreign_keys = ON");

export function ensureGovernanceRuntimeTables(): void {
  sqlite.exec(`
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
  `);
}

const requiredPackageTextFields = [

  "package_id",

  "requested_outcome",

  "scope",

  "containment",

  "constraints",

  "success_criteria",

] as const;

const requiredDelegationTextFields = [

  "delegation_id",

  "package_id",

  "authorization_state",

  "delegated_by",

] as const;

const requiredValidationTextFields = [

  "validation_result_id",

  "package_id",

  "delegation_id",

  "validation_status",

] as const;

const requiredEnvelopeGateTextFields = [

  "envelope_gate_id",

  "package_id",

  "delegation_id",

  "validation_result_id",

  "gate_status",

] as const;

const requiredEnvelopeTextFields = [

  "envelope_id",

  "package_id",

  "delegation_id",

  "validation_result_id",

  "envelope_gate_id",

  "validation_status",

  "lifecycle_state",

] as const;

function requirePackageText(

  input: CreateGovernancePackageInput,

  field: (typeof requiredPackageTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Package field: ${field}`);

  }

  return value;

}

function requireDelegationText(

  input: CreateGovernanceDelegationInput,

  field: (typeof requiredDelegationTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Delegation field: ${field}`);

  }

  return value;

}

function requireValidationText(

  input: CreateGovernanceValidationResultInput,

  field: (typeof requiredValidationTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Validation field: ${field}`);

  }

  return value;

}

function requireEnvelopeGateText(

  input: CreateGovernanceEnvelopeGateInput,

  field: (typeof requiredEnvelopeGateTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Envelope Gate field: ${field}`);

  }

  return value;

}

function requireEnvelopeText(

  input: CreateGovernanceEnvelopeInput,

  field: (typeof requiredEnvelopeTextFields)[number],

): string {

  const value = input[field];

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance Envelope field: ${field}`);

  }

  return value;

}

function requirePackageVersion(

  value: unknown,

  artifact: "Package" | "Delegation" | "Validation" | "Envelope Gate" | "Envelope",

): number {

  if (!Number.isInteger(value) || Number(value) < 1) {

    throw new Error(`Missing required governance ${artifact} field: package_version`);

  }

  return Number(value);

}

function optionalText(value: string | null | undefined): string | null {

  if (value === undefined || value === null) {

    return null;

  }

  return String(value);

}

function optionalTimestamp(

  value: string | null | undefined,

  artifact: "Delegation" | "Validation" | "Envelope Gate",

  field: "authorization_timestamp" | "validation_timestamp" | "gate_decision_timestamp",

): string {

  if (value === undefined || value === null) {

    return new Date().toISOString();

  }

  if (typeof value !== "string" || value.trim().length === 0) {

    throw new Error(`Missing required governance ${artifact} field: ${field}`);

  }

  return value;

}

export function createGovernancePackage(input: CreateGovernancePackageInput): CreatedGovernancePackage {

  ensureGovernanceRuntimeTables();

  const package_id = requirePackageText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Package");

  const requested_outcome = requirePackageText(input, "requested_outcome");

  const scope = requirePackageText(input, "scope");

  const containment = requirePackageText(input, "containment");

  const constraints = requirePackageText(input, "constraints");

  const success_criteria = requirePackageText(input, "success_criteria");

  const created_at = new Date().toISOString();

  sqlite.prepare(`

    INSERT INTO governance_packages (

      package_id,

      package_version,

      requested_outcome,

      scope,

      containment,

      constraints,

      success_criteria,

      context,

      style_presentation_intent,

      exclusions,

      created_at

    ) VALUES (

      @package_id,

      @package_version,

      @requested_outcome,

      @scope,

      @containment,

      @constraints,

      @success_criteria,

      @context,

      @style_presentation_intent,

      @exclusions,

      @created_at

    )

  `).run({

    package_id,

    package_version,

    requested_outcome,

    scope,

    containment,

    constraints,

    success_criteria,

    context: optionalText(input.context),

    style_presentation_intent: optionalText(input.style_presentation_intent),

    exclusions: optionalText(input.exclusions),

    created_at,

  });

  return {

    package_id,

    package_version,

    created_at,

  };

}

export function createGovernanceDelegation(

  input: CreateGovernanceDelegationInput,

): CreatedGovernanceDelegation {

  ensureGovernanceRuntimeTables();

  const delegation_id = requireDelegationText(input, "delegation_id");

  const package_id = requireDelegationText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Delegation");

  const authorization_state = requireDelegationText(input, "authorization_state");

  const authorization_timestamp = optionalTimestamp(input.authorization_timestamp, "Delegation", "authorization_timestamp");

  const delegated_by = requireDelegationText(input, "delegated_by");

  const created_at = new Date().toISOString();

  sqlite.prepare(`

    INSERT INTO governance_delegations (

      delegation_id,

      package_id,

      package_version,

      authorization_state,

      authorization_timestamp,

      delegated_by,

      created_at

    ) VALUES (

      @delegation_id,

      @package_id,

      @package_version,

      @authorization_state,

      @authorization_timestamp,

      @delegated_by,

      @created_at

    )

  `).run({

    delegation_id,

    package_id,

    package_version,

    authorization_state,

    authorization_timestamp,

    delegated_by,

    created_at,

  });

  return {

    delegation_id,

    package_id,

    package_version,

    authorization_state,

    authorization_timestamp,

    delegated_by,

    created_at,

  };

}

export function createGovernanceValidationResult(

  input: CreateGovernanceValidationResultInput,

): CreatedGovernanceValidationResult {

  ensureGovernanceRuntimeTables();

  const validation_result_id = requireValidationText(input, "validation_result_id");

  const package_id = requireValidationText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Validation");

  const delegation_id = requireValidationText(input, "delegation_id");

  const validation_status = requireValidationText(input, "validation_status");

  const validation_timestamp = optionalTimestamp(input.validation_timestamp, "Validation", "validation_timestamp");

  const created_at = new Date().toISOString();

  sqlite.prepare(`

    INSERT INTO governance_validation_results (

      validation_result_id,

      package_id,

      package_version,

      delegation_id,

      validation_status,

      governance_findings,

      operational_requirements,

      capability_requirements,

      escalations,

      validation_timestamp,

      created_at

    ) VALUES (

      @validation_result_id,

      @package_id,

      @package_version,

      @delegation_id,

      @validation_status,

      @governance_findings,

      @operational_requirements,

      @capability_requirements,

      @escalations,

      @validation_timestamp,

      @created_at

    )

  `).run({

    validation_result_id,

    package_id,

    package_version,

    delegation_id,

    validation_status,

    governance_findings: optionalText(input.governance_findings),

    operational_requirements: optionalText(input.operational_requirements),

    capability_requirements: optionalText(input.capability_requirements),

    escalations: optionalText(input.escalations),

    validation_timestamp,

    created_at,

  });

  return {

    validation_result_id,

    package_id,

    package_version,

    delegation_id,

    validation_status,

    validation_timestamp,

    created_at,

  };

}

export function createGovernanceEnvelopeGate(

  input: CreateGovernanceEnvelopeGateInput,

): CreatedGovernanceEnvelopeGate {

  ensureGovernanceRuntimeTables();

  const envelope_gate_id = requireEnvelopeGateText(input, "envelope_gate_id");

  const package_id = requireEnvelopeGateText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Envelope Gate");

  const delegation_id = requireEnvelopeGateText(input, "delegation_id");

  const validation_result_id = requireEnvelopeGateText(input, "validation_result_id");

  const gate_status = requireEnvelopeGateText(input, "gate_status");

  const gate_decision_timestamp = optionalTimestamp(

    input.gate_decision_timestamp,

    "Envelope Gate",

    "gate_decision_timestamp",

  );

  const created_at = new Date().toISOString();

  sqlite.prepare(`

    INSERT INTO governance_envelope_gates (

      envelope_gate_id,

      package_id,

      package_version,

      delegation_id,

      validation_result_id,

      gate_status,

      gate_reason,

      gate_decision_timestamp,

      created_at

    ) VALUES (

      @envelope_gate_id,

      @package_id,

      @package_version,

      @delegation_id,

      @validation_result_id,

      @gate_status,

      @gate_reason,

      @gate_decision_timestamp,

      @created_at

    )

  `).run({

    envelope_gate_id,

    package_id,

    package_version,

    delegation_id,

    validation_result_id,

    gate_status,

    gate_reason: optionalText(input.gate_reason),

    gate_decision_timestamp,

    created_at,

  });

  return {

    envelope_gate_id,

    package_id,

    package_version,

    delegation_id,

    validation_result_id,

    gate_status,

    gate_decision_timestamp,

    created_at,

  };

}

export function createGovernanceEnvelope(

  input: CreateGovernanceEnvelopeInput,

): CreatedGovernanceEnvelope {

  ensureGovernanceRuntimeTables();

  const envelope_id = requireEnvelopeText(input, "envelope_id");

  const package_id = requireEnvelopeText(input, "package_id");

  const package_version = requirePackageVersion(input.package_version, "Envelope");

  const delegation_id = requireEnvelopeText(input, "delegation_id");

  const validation_result_id = requireEnvelopeText(input, "validation_result_id");

  const envelope_gate_id = requireEnvelopeText(input, "envelope_gate_id");

  const validation_status = requireEnvelopeText(input, "validation_status");

  const lifecycle_state = requireEnvelopeText(input, "lifecycle_state");

  const created_at = new Date().toISOString();

  sqlite.prepare(`

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

      @envelope_id,

      @package_id,

      @package_version,

      @delegation_id,

      @validation_result_id,

      @envelope_gate_id,

      @validation_status,

      @required_capabilities,

      @operational_corridor,

      @lifecycle_state,

      @created_at

    )

  `).run({

    envelope_id,

    package_id,

    package_version,

    delegation_id,

    validation_result_id,

    envelope_gate_id,

    validation_status,

    required_capabilities: optionalText(input.required_capabilities),

    operational_corridor: optionalText(input.operational_corridor),

    lifecycle_state,

    created_at,

  });

  return {

    envelope_id,

    package_id,

    package_version,

    delegation_id,

    validation_result_id,

    envelope_gate_id,

    validation_status,

    lifecycle_state,

    created_at,

  };

}

