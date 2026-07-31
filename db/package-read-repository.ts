import Database from "better-sqlite3";

export interface LivingDraftPackageReadRecord {
  draft_package_id: string;
  lineage_id: string;
  current_interpretation: string;
  proposed_work: string | null;
  proposed_artifacts: string | null;
  in_scope: string | null;
  out_of_scope: string | null;
  constraints: string | null;
  expected_outcome: string | null;
  unresolved_questions: string | null;
  evidence_entry_ids: string;
  status: string;
  created_at: string;
  updated_at: string;
  project_id: string | null;
  conversation_id: string | null;
}

export interface PackageReadRepository {
  listLivingDraftPackagesByProject(
    projectId: string,
  ): LivingDraftPackageReadRecord[];

  getLivingDraftPackageById(
    projectId: string,
    draftPackageId: string,
  ): LivingDraftPackageReadRecord | null;

  close(): void;
}

function requireIdentifier(value: string, name: string): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(`${name} is required.`);
  }

  return normalized;
}

export function createPackageReadRepository(
  databasePath = "db/main.db",
): PackageReadRepository {
  const db = new Database(databasePath, {
    readonly: true,
    fileMustExist: true,
  });

  const listStatement = db.prepare(`
    SELECT
      draft_package_id,
      lineage_id,
      current_interpretation,
      proposed_work,
      proposed_artifacts,
      in_scope,
      out_of_scope,
      constraints,
      expected_outcome,
      unresolved_questions,
      evidence_entry_ids,
      status,
      created_at,
      updated_at,
      project_id,
      conversation_id
    FROM matilda_living_draft_packages
    WHERE project_id = ?
    ORDER BY updated_at DESC, draft_package_id ASC
  `);

  const detailStatement = db.prepare(`
    SELECT
      draft_package_id,
      lineage_id,
      current_interpretation,
      proposed_work,
      proposed_artifacts,
      in_scope,
      out_of_scope,
      constraints,
      expected_outcome,
      unresolved_questions,
      evidence_entry_ids,
      status,
      created_at,
      updated_at,
      project_id,
      conversation_id
    FROM matilda_living_draft_packages
    WHERE project_id = ?
      AND draft_package_id = ?
    LIMIT 1
  `);

  return {
    listLivingDraftPackagesByProject(projectId) {
      return listStatement.all(
        requireIdentifier(projectId, "projectId"),
      ) as LivingDraftPackageReadRecord[];
    },

    getLivingDraftPackageById(projectId, draftPackageId) {
      return (
        (detailStatement.get(
          requireIdentifier(projectId, "projectId"),
          requireIdentifier(draftPackageId, "draftPackageId"),
        ) as LivingDraftPackageReadRecord | undefined) ?? null
      );
    },

    close() {
      db.close();
    },
  };
}
