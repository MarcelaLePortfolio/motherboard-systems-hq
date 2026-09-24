import Database, { type Database as DatabaseType } from "better-sqlite3";

export type GovernanceEnvelopeGateValidationIdentity = {
  validation_result_id: string;
  delegation_id: string;
  package_id: string;
  package_version: number;
};

export type GovernanceEnvelopeGateValidationReadRecord = {
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

export type GovernanceEnvelopeGateValidationLoader = (
  identity: GovernanceEnvelopeGateValidationIdentity,
) => GovernanceEnvelopeGateValidationReadRecord;

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(
      `Missing required governance Envelope Gate validation read field: ${field}`,
    );
  }

  return value.trim();
}

function requirePackageVersion(value: unknown): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw new Error(
      "Missing required governance Envelope Gate validation read field: package_version",
    );
  }

  return Number(value);
}

export function loadExactGovernanceEnvelopeGateValidationResult(
  db: DatabaseType,
  identity: GovernanceEnvelopeGateValidationIdentity,
): GovernanceEnvelopeGateValidationReadRecord {
  const validation_result_id = requireText(
    identity.validation_result_id,
    "validation_result_id",
  );
  const delegation_id = requireText(identity.delegation_id, "delegation_id");
  const package_id = requireText(identity.package_id, "package_id");
  const package_version = requirePackageVersion(identity.package_version);

  const rows = db.prepare(`
    SELECT
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
  ) as GovernanceEnvelopeGateValidationReadRecord[];

  if (rows.length !== 1) {
    throw new Error(
      "Governance Envelope Gate validation result not found or ambiguous.",
    );
  }

  return rows[0];
}

export function createGovernanceEnvelopeGateValidationLoader(
  databasePath = "db/main.db",
): GovernanceEnvelopeGateValidationLoader {
  return (identity) => {
    const db = new Database(databasePath, {
      readonly: true,
      fileMustExist: true,
    });

    try {
      return loadExactGovernanceEnvelopeGateValidationResult(db, identity);
    } finally {
      db.close();
    }
  };
}
