import Database from "better-sqlite3";

export type AtlasCanonicalPackageObservation = {
  observationType: "canonical_package";
  authority: "authoritative";
  status: "canonical_approved";
  projectId: string;
  conversationId: string | null;
  packageId: string;
  packageVersion: number;
  draftRevisionId: string | null;
  lineageId: string;
  approvalActor: string;
  approvalTimestamp: string;
};

type CanonicalPackageSourceRecord = {
  package_id: string;
  package_version: number;
  draft_revision_id: string | null;
  lineage_id: string;
  project_id: string | null;
  conversation_id: string | null;
  approval_actor: string;
  approval_timestamp: string;
  status: string;
};

function requireProjectId(projectId: string): string {
  if (typeof projectId !== "string" || projectId.trim().length === 0) {
    throw new Error(
      "Atlas canonical Package observation requires projectId.",
    );
  }

  return projectId.trim();
}

function adaptCanonicalPackageForAtlas(
  record: CanonicalPackageSourceRecord,
  expectedProjectId: string,
): AtlasCanonicalPackageObservation {
  if (record.project_id !== expectedProjectId) {
    throw new Error(
      "Atlas canonical Package observation crossed project scope.",
    );
  }

  if (record.status !== "canonical_approved") {
    throw new Error(
      "Atlas canonical Package observation requires canonical_approved status.",
    );
  }

  if (
    typeof record.package_id !== "string"
    || record.package_id.trim().length === 0
    || !Number.isInteger(record.package_version)
    || record.package_version < 1
    || typeof record.lineage_id !== "string"
    || record.lineage_id.trim().length === 0
    || typeof record.approval_actor !== "string"
    || record.approval_actor.trim().length === 0
    || typeof record.approval_timestamp !== "string"
    || record.approval_timestamp.trim().length === 0
  ) {
    throw new Error(
      "Atlas canonical Package observation encountered invalid canonical identity.",
    );
  }

  return {
    observationType: "canonical_package",
    authority: "authoritative",
    status: "canonical_approved",
    projectId: expectedProjectId,
    conversationId: record.conversation_id,
    packageId: record.package_id,
    packageVersion: record.package_version,
    draftRevisionId: record.draft_revision_id,
    lineageId: record.lineage_id,
    approvalActor: record.approval_actor,
    approvalTimestamp: record.approval_timestamp,
  };
}

export function readAtlasCanonicalPackageObservations(
  projectId: string,
  databasePath = "db/main.db",
): AtlasCanonicalPackageObservation[] {
  const normalizedProjectId = requireProjectId(projectId);

  const database = new Database(databasePath, {
    readonly: true,
    fileMustExist: true,
  });

  try {
    const records = database
      .prepare(`
        SELECT
          package_id,
          package_version,
          draft_revision_id,
          lineage_id,
          project_id,
          conversation_id,
          approval_actor,
          approval_timestamp,
          status
        FROM matilda_canonical_packages
        WHERE project_id = ?
          AND status = 'canonical_approved'
        ORDER BY approval_timestamp ASC, package_version ASC
      `)
      .all(normalizedProjectId) as CanonicalPackageSourceRecord[];

    return records.map((record) =>
      adaptCanonicalPackageForAtlas(
        record,
        normalizedProjectId,
      ),
    );
  } finally {
    database.close();
  }
}
