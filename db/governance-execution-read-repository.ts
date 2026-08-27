import type { Database } from "better-sqlite3";

import {
  assertEnvelopeCreationEligible,
  assertValidationEligible,
} from "./governance-lifecycle-enforcement";

export type GovernanceExecutionReadIdentity = {
  envelope_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  envelope_gate_id: string;
};

export type GovernanceExecutionReadChain = {
  delegation: {
    delegation_id: string;
    project_id: string;
    package_id: string;
    package_version: number;
    authorization_state: string;
    authorization_timestamp: string;
    delegated_by: string;
    created_at: string;
  };
  validation_result: {
    validation_result_id: string;
    package_id: string;
    package_version: number;
    delegation_id: string;
    validation_status: string;
    governance_findings: string | null;
    operational_requirements: string | null;
    capability_requirements: string | null;
    escalations: string | null;
    validation_timestamp: string;
    created_at: string;
  };
  envelope_gate: {
    envelope_gate_id: string;
    package_id: string;
    package_version: number;
    delegation_id: string;
    validation_result_id: string;
    gate_status: string;
    gate_reason: string | null;
    gate_decision_timestamp: string;
    created_at: string;
  };
  envelope: {
    envelope_id: string;
    package_id: string;
    package_version: number;
    delegation_id: string;
    validation_result_id: string;
    envelope_gate_id: string;
    validation_status: string;
    required_capabilities: string | null;
    operational_corridor: string | null;
    lifecycle_state: string;
    created_at: string;
  };
  governance: {
    ok: true;
    authorization_state: string;
    validation_status: string;
    gate_status: string;
  };
};

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Missing required governance execution read field: ${field}`);
  }
  return value.trim();
}

function requirePackageVersion(value: unknown): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw new Error(
      "Missing required governance execution read field: package_version",
    );
  }
  return Number(value);
}

function requireExactlyOne<T>(rows: T[], label: string): T {
  if (rows.length !== 1) {
    throw new Error(`Governance execution ${label} not found or ambiguous.`);
  }
  return rows[0];
}

export function loadGovernanceExecutionReadChain(
  db: Database,
  identity: GovernanceExecutionReadIdentity,
): GovernanceExecutionReadChain {
  const envelope_id = requireText(identity.envelope_id, "envelope_id");
  const package_id = requireText(identity.package_id, "package_id");
  const package_version = requirePackageVersion(identity.package_version);
  const delegation_id = requireText(identity.delegation_id, "delegation_id");
  const validation_result_id = requireText(identity.validation_result_id, "validation_result_id");
  const envelope_gate_id = requireText(identity.envelope_gate_id, "envelope_gate_id");

  const delegation = requireExactlyOne(
    db.prepare(`
      SELECT delegation_id, project_id, package_id, package_version,
             authorization_state, authorization_timestamp, delegated_by, created_at
      FROM governance_delegations
      WHERE delegation_id = ? AND package_id = ? AND package_version = ?
      LIMIT 2
    `).all(delegation_id, package_id, package_version) as GovernanceExecutionReadChain["delegation"][],
    "delegation",
  );

  const validationResult = requireExactlyOne(
    db.prepare(`
      SELECT validation_result_id, package_id, package_version, delegation_id,
             validation_status, governance_findings, operational_requirements,
             capability_requirements, escalations, validation_timestamp, created_at
      FROM governance_validation_results
      WHERE validation_result_id = ? AND delegation_id = ?
        AND package_id = ? AND package_version = ?
      LIMIT 2
    `).all(
      validation_result_id,
      delegation_id,
      package_id,
      package_version,
    ) as GovernanceExecutionReadChain["validation_result"][],
    "validation result",
  );

  const envelopeGate = requireExactlyOne(
    db.prepare(`
      SELECT envelope_gate_id, package_id, package_version, delegation_id,
             validation_result_id, gate_status, gate_reason,
             gate_decision_timestamp, created_at
      FROM governance_envelope_gates
      WHERE envelope_gate_id = ? AND validation_result_id = ?
        AND delegation_id = ? AND package_id = ? AND package_version = ?
      LIMIT 2
    `).all(
      envelope_gate_id,
      validation_result_id,
      delegation_id,
      package_id,
      package_version,
    ) as GovernanceExecutionReadChain["envelope_gate"][],
    "envelope gate",
  );

  const envelope = requireExactlyOne(
    db.prepare(`
      SELECT envelope_id, package_id, package_version, delegation_id,
             validation_result_id, envelope_gate_id, validation_status,
             required_capabilities, operational_corridor, lifecycle_state, created_at
      FROM governance_envelopes
      WHERE envelope_id = ? AND envelope_gate_id = ?
        AND validation_result_id = ? AND delegation_id = ?
        AND package_id = ? AND package_version = ?
      LIMIT 2
    `).all(
      envelope_id,
      envelope_gate_id,
      validation_result_id,
      delegation_id,
      package_id,
      package_version,
    ) as GovernanceExecutionReadChain["envelope"][],
    "envelope",
  );

  if (
    validationResult.delegation_id !== delegation.delegation_id ||
    envelopeGate.delegation_id !== delegation.delegation_id ||
    envelopeGate.validation_result_id !== validationResult.validation_result_id ||
    envelope.delegation_id !== delegation.delegation_id ||
    envelope.validation_result_id !== validationResult.validation_result_id ||
    envelope.envelope_gate_id !== envelopeGate.envelope_gate_id
  ) {
    throw new Error("Governance execution artifact lineage mismatch.");
  }

  assertValidationEligible({ delegation });
  assertEnvelopeCreationEligible({
    validationResult,
    envelopeGate,
    envelope,
  });

  return {
    delegation,
    validation_result: validationResult,
    envelope_gate: envelopeGate,
    envelope,
    governance: {
      ok: true,
      authorization_state: delegation.authorization_state,
      validation_status: validationResult.validation_status,
      gate_status: envelopeGate.gate_status,
    },
  };
}
