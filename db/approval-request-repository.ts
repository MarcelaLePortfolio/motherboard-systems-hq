import Database from "better-sqlite3";

export type ApprovalRequestSourceRecord = {
  draft_package_id: string;
  lineage_id: string;
  project_id: string;
  conversation_id: string | null;
  current_interpretation: string;
  proposed_work: string | null;
  proposed_artifacts: string | null;
  in_scope: string | null;
  out_of_scope: string | null;
  constraints: string | null;
  expected_outcome: string | null;
  unresolved_questions: string | null;
  evidence_entry_ids: string;
  source_draft_status: string;
  created_at: string;
  updated_at: string;
};

export interface ApprovalRequestRepository {
  listPendingCanonicalPackageApprovalsByProject(
    projectId: string,
  ): ApprovalRequestSourceRecord[];

  getPendingCanonicalPackageApprovalById(
    projectId: string,
    draftPackageId: string,
  ): ApprovalRequestSourceRecord | null;

  close(): void;
}

function requireIdentifier(value: string, name: string): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(`${name} is required.`);
  }

  return normalized;
}

export function createApprovalRequestRepository(
  databasePath = "db/main.db",
): ApprovalRequestRepository {
  const db = new Database(databasePath, {
    readonly: true,
    fileMustExist: true,
  });

  const listStatement = db.prepare(`
    SELECT
      draft.draft_package_id,
      draft.lineage_id,
      draft.project_id,
      draft.conversation_id,
      draft.current_interpretation,
      draft.proposed_work,
      draft.proposed_artifacts,
      draft.in_scope,
      draft.out_of_scope,
      draft.constraints,
      draft.expected_outcome,
      draft.unresolved_questions,
      draft.evidence_entry_ids,
      draft.status AS source_draft_status,
      draft.created_at,
      draft.updated_at
    FROM matilda_living_draft_packages AS draft
    LEFT JOIN matilda_canonical_packages AS canonical
      ON canonical.draft_package_id = draft.draft_package_id
    WHERE draft.project_id = ?
      AND canonical.package_id IS NULL
    ORDER BY draft.updated_at DESC, draft.draft_package_id ASC
  `);

  const detailStatement = db.prepare(`
    SELECT
      draft.draft_package_id,
      draft.lineage_id,
      draft.project_id,
      draft.conversation_id,
      draft.current_interpretation,
      draft.proposed_work,
      draft.proposed_artifacts,
      draft.in_scope,
      draft.out_of_scope,
      draft.constraints,
      draft.expected_outcome,
      draft.unresolved_questions,
      draft.evidence_entry_ids,
      draft.status AS source_draft_status,
      draft.created_at,
      draft.updated_at
    FROM matilda_living_draft_packages AS draft
    LEFT JOIN matilda_canonical_packages AS canonical
      ON canonical.draft_package_id = draft.draft_package_id
    WHERE draft.project_id = ?
      AND draft.draft_package_id = ?
      AND canonical.package_id IS NULL
    LIMIT 1
  `);

  return {
    listPendingCanonicalPackageApprovalsByProject(projectId) {
      return listStatement.all(
        requireIdentifier(projectId, "projectId"),
      ) as ApprovalRequestSourceRecord[];
    },

    getPendingCanonicalPackageApprovalById(projectId, draftPackageId) {
      return (
        (detailStatement.get(
          requireIdentifier(projectId, "projectId"),
          requireIdentifier(draftPackageId, "draftPackageId"),
        ) as ApprovalRequestSourceRecord | undefined) ?? null
      );
    },

    close() {
      db.close();
    },
  };
}
