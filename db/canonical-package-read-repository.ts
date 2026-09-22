import Database from "better-sqlite3";

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
}

export interface CanonicalPackageReadRepository {
  listByProject(projectId: string): CanonicalPackageReadRecord[];
  close(): void;
}

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

  return {
    listByProject(projectId) {
      return listStatement.all(
        requireIdentifier(projectId, "projectId"),
      ) as CanonicalPackageReadRecord[];
    },

    close() {
      db.close();
    },
  };
}
