import Database, { type Database as DatabaseType } from "better-sqlite3";

export type GovernanceEnvelopeCreationIdentity = {
  validation_result_id: string;
  envelope_gate_id: string;
  delegation_id: string;
  package_id: string;
  package_version: number;
};

export type GovernanceEnvelopeCreationValidationRecord = {
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

export type GovernanceEnvelopeCreationGateRecord = {
  envelope_gate_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  gate_status: string;
  gate_reason: string | null;
  gate_decision_timestamp: string | null;
  created_at: string;
};

export type GovernanceEnvelopeCreationReadChain = {
  validation_result: GovernanceEnvelopeCreationValidationRecord;
  envelope_gate: GovernanceEnvelopeCreationGateRecord;
};

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(
      `Missing required governance Envelope creation read field: ${field}`,
    );
  }
  return value.trim();
}

function requirePackageVersion(value: unknown): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw new Error(
      "Missing required governance Envelope creation read field: package_version",
    );
  }
  return Number(value);
}

function requireExactlyOne<T>(rows: T[], artifact: string): T {
  if (rows.length !== 1) {
    throw new Error(
      `Governance Envelope creation ${artifact} not found or ambiguous.`,
    );
  }
  return rows[0];
}

export function loadExactGovernanceEnvelopeCreationReadChain(
  db: DatabaseType,
  identity: GovernanceEnvelopeCreationIdentity,
): GovernanceEnvelopeCreationReadChain {
  const validation_result_id = requireText(
    identity.validation_result_id,
    "validation_result_id",
  );
  const envelope_gate_id = requireText(
    identity.envelope_gate_id,
    "envelope_gate_id",
  );
  const delegation_id = requireText(identity.delegation_id, "delegation_id");
  const package_id = requireText(identity.package_id, "package_id");
  const package_version = requirePackageVersion(identity.package_version);

  const validation_result = requireExactlyOne(
    db.prepare(`
      SELECT validation_result_id, package_id, package_version, delegation_id,
             validation_status, governance_findings, operational_requirements,
             capability_requirements, escalations, validation_timestamp, created_at
      FROM governance_validation_results
      WHERE validation_result_id = ?
        AND delegation_id = ?
        AND package_id = ?
        AND package_version = ?
      LIMIT 2
    `).all(
      validation_result_id,
      delegation_id,
      package_id,
      package_version,
    ) as GovernanceEnvelopeCreationValidationRecord[],
    "validation result",
  );

  const envelope_gate = requireExactlyOne(
    db.prepare(`
      SELECT envelope_gate_id, package_id, package_version, delegation_id,
             validation_result_id, gate_status, gate_reason,
             gate_decision_timestamp, created_at
      FROM governance_envelope_gates
      WHERE envelope_gate_id = ?
        AND validation_result_id = ?
        AND delegation_id = ?
        AND package_id = ?
        AND package_version = ?
      LIMIT 2
    `).all(
      envelope_gate_id,
      validation_result_id,
      delegation_id,
      package_id,
      package_version,
    ) as GovernanceEnvelopeCreationGateRecord[],
    "envelope gate",
  );

  return {
    validation_result,
    envelope_gate,
  };
}

export type GovernanceEnvelopeCreationReadLoader = (
  identity: GovernanceEnvelopeCreationIdentity,
) => GovernanceEnvelopeCreationReadChain;

export function createGovernanceEnvelopeCreationReadLoader(
  databasePath = "db/main.db",
): GovernanceEnvelopeCreationReadLoader {
  return (identity) => {
    const db = new Database(databasePath, {
      readonly: true,
      fileMustExist: true,
    });

    try {
      return loadExactGovernanceEnvelopeCreationReadChain(db, identity);
    } finally {
      db.close();
    }
  };
}
