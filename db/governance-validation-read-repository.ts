import Database from "better-sqlite3";

export type GovernanceValidationDelegationIdentity = {
  delegation_id: string;
  package_id: string;
  package_version: number;
};

export type GovernanceValidationDelegationReadRecord = {
  delegation_id: string;
  package_id: string;
  package_version: number;
  authorization_state: string;
};

export type GovernanceValidationDelegationLoader = (
  identity: GovernanceValidationDelegationIdentity,
) => GovernanceValidationDelegationReadRecord;

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Missing required governance Validation read field: ${field}`);
  }

  return value.trim();
}

function requirePackageVersion(value: unknown): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw new Error(
      "Missing required governance Validation read field: package_version",
    );
  }

  return Number(value);
}

export function createGovernanceValidationDelegationLoader(
  databasePath = "db/main.db",
): GovernanceValidationDelegationLoader {
  return (identity) => {
    const delegation_id = requireText(identity.delegation_id, "delegation_id");
    const package_id = requireText(identity.package_id, "package_id");
    const package_version = requirePackageVersion(identity.package_version);

    const db = new Database(databasePath, {
      readonly: true,
      fileMustExist: true,
    });

    try {
      const rows = db.prepare(`
        SELECT
          delegation_id,
          package_id,
          package_version,
          authorization_state
        FROM governance_delegations
        WHERE delegation_id = ?
          AND package_id = ?
          AND package_version = ?
        LIMIT 2
      `).all(
        delegation_id,
        package_id,
        package_version,
      ) as GovernanceValidationDelegationReadRecord[];

      if (rows.length !== 1) {
        throw new Error(
          "Governance Validation delegation not found or ambiguous.",
        );
      }

      return rows[0];
    } finally {
      db.close();
    }
  };
}
