import Database from "better-sqlite3";

export type CanonicalPackageDelegationState =
  | {
      state: "awaiting_delegation";
      delegation_id: null;
      authorization_state: null;
      authorization_timestamp: null;
      delegated_by: null;
    }
  | {
      state: "delegated";
      delegation_id: string;
      authorization_state: "AUTHORIZED";
      authorization_timestamp: string;
      delegated_by: string;
    }
  | {
      state: "ambiguous";
      delegation_id: null;
      authorization_state: null;
      authorization_timestamp: null;
      delegated_by: null;
    };

export interface CanonicalPackageReadRecord {
  package_id: string;
  package_version: number;
  summary_id: string;
  draft_package_id: string;
  draft_revision_id: string | null;
  lineage_id: string;
  project_id: string;
  conversation_id: string | null;
  approved_interpretation: string;
  approved_work: string | null;
  approved_artifacts: string | null;
  approved_scope: string | null;
  approved_constraints: string | null;
  approved_expected_outcome: string | null;
  approval_actor: string;
  approval_timestamp: string;
  status: "canonical_approved";
  created_at: string;
  delegation: CanonicalPackageDelegationState;
}

export interface CanonicalPackageReadRepository {
  listByProject(projectId: string): CanonicalPackageReadRecord[];
  close(): void;
}

type CanonicalPackageRow = Omit<
  CanonicalPackageReadRecord,
  "delegation"
>;

type DelegationRow = {
  delegation_id: string;
  authorization_state: string;
  authorization_timestamp: string;
  delegated_by: string;
};

function requireIdentifier(
  value: string,
  name: string,
): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(`${name} is required.`);
  }

  return normalized;
}

function readDelegationState(
  rows: DelegationRow[],
): CanonicalPackageDelegationState {
  if (rows.length === 0) {
    return {
      state: "awaiting_delegation",
      delegation_id: null,
      authorization_state: null,
      authorization_timestamp: null,
      delegated_by: null,
    };
  }

  if (rows.length !== 1) {
    return {
      state: "ambiguous",
      delegation_id: null,
      authorization_state: null,
      authorization_timestamp: null,
      delegated_by: null,
    };
  }

  const row = rows[0];

  if (
    row.authorization_state !== "AUTHORIZED" ||
    !row.delegation_id.trim() ||
    !row.authorization_timestamp.trim() ||
    !row.delegated_by.trim()
  ) {
    return {
      state: "ambiguous",
      delegation_id: null,
      authorization_state: null,
      authorization_timestamp: null,
      delegated_by: null,
    };
  }

  return {
    state: "delegated",
    delegation_id: row.delegation_id,
    authorization_state: "AUTHORIZED",
    authorization_timestamp: row.authorization_timestamp,
    delegated_by: row.delegated_by,
  };
}

export function createCanonicalPackageReadRepository(
  databasePath = "db/main.db",
): CanonicalPackageReadRepository {
  const db = new Database(databasePath, {
    readonly: true,
    fileMustExist: true,
  });

  const listStatement = db.prepare(`
    SELECT
      package_id,
      package_version,
      summary_id,
      draft_package_id,
      draft_revision_id,
      lineage_id,
      project_id,
      conversation_id,
      approved_interpretation,
      approved_work,
      approved_artifacts,
      approved_scope,
      approved_constraints,
      approved_expected_outcome,
      approval_actor,
      approval_timestamp,
      status,
      created_at
    FROM matilda_canonical_packages
    WHERE project_id = ?
      AND status = 'canonical_approved'
    ORDER BY approval_timestamp DESC, package_version DESC
  `);

  const delegationStatement = db.prepare(`
    SELECT
      delegation_id,
      authorization_state,
      authorization_timestamp,
      delegated_by
    FROM governance_delegations
    WHERE project_id = ?
      AND package_id = ?
      AND package_version = ?
    ORDER BY created_at DESC
    LIMIT 2
  `);

  return {
    listByProject(projectId) {
      const normalizedProjectId = requireIdentifier(
        projectId,
        "projectId",
      );

      const packages = listStatement.all(
        normalizedProjectId,
      ) as CanonicalPackageRow[];

      return packages.map((pkg) => {
        const delegationRows = delegationStatement.all(
          normalizedProjectId,
          pkg.package_id,
          pkg.package_version,
        ) as DelegationRow[];

        return {
          ...pkg,
          delegation: readDelegationState(delegationRows),
        };
      });
    },

    close() {
      db.close();
    },
  };
}
