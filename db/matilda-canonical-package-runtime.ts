import { randomUUID } from "node:crypto";

import Database from "better-sqlite3";

import { initializeDraftRevisionSchema } from "./matilda-draft-revision-runtime";
import { generateReconciledIntentSummary } from "./matilda-reconciled-intent-runtime";
import { projectCanonicalPackageToMissionPackage } from "./canonical-package-mission-projection";

const sqlite = new Database("db/main.db");

sqlite.pragma("foreign_keys = ON");

export class CanonicalPackageSchemaUnavailableError extends Error {
  readonly code = "CANONICAL_PACKAGE_SCHEMA_UNAVAILABLE";

  constructor(
    message =
      "Canonical Package schema has not been initialized. " +
      "initializeCanonicalPackageSchema() must complete successfully during " +
      "application startup before Canonical Package creation can proceed.",
  ) {
    super(message);
    this.name = "CanonicalPackageSchemaUnavailableError";
    Object.setPrototypeOf(
      this,
      CanonicalPackageSchemaUnavailableError.prototype,
    );
  }
}

function createCanonicalPackageTable() {
  sqlite.exec(`
    CREATE TABLE IF NOT EXISTS matilda_canonical_packages (
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL CHECK (package_version >= 1),
      summary_id TEXT NOT NULL,
      draft_package_id TEXT NOT NULL,
      draft_revision_id TEXT,
      lineage_id TEXT NOT NULL,
      project_id TEXT,
      conversation_id TEXT,
      approved_interpretation TEXT NOT NULL,
      approved_work TEXT,
      approved_artifacts TEXT,
      approved_scope TEXT,
      approved_constraints TEXT,
      approved_expected_outcome TEXT,
      approval_actor TEXT NOT NULL,
      approval_timestamp TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      PRIMARY KEY (package_id, package_version)
    )
  `);
}

function migrateLegacyCanonicalPackageTableIfRequired() {
  const table = sqlite
    .prepare(`
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name = 'matilda_canonical_packages'
      LIMIT 1
    `)
    .get() as { name: string } | undefined;

  if (!table) {
    createCanonicalPackageTable();
    return;
  }

  const columns = sqlite
    .prepare("PRAGMA table_info(matilda_canonical_packages)")
    .all() as Array<{
      name: string;
      pk: number;
    }>;

  const hasPackageVersion = columns.some(
    (column) => column.name === "package_version",
  );

  const hasDraftRevisionId = columns.some(
    (column) => column.name === "draft_revision_id",
  );

  const packageIdPrimaryKeyOnly =
    columns.find((column) => column.name === "package_id")?.pk === 1
    && !columns.some(
      (column) =>
        column.name === "package_version"
        && column.pk > 0,
    );

  if (
    hasPackageVersion
    && hasDraftRevisionId
    && !packageIdPrimaryKeyOnly
  ) {
    return;
  }

  sqlite.transaction(() => {
    sqlite.exec(`
      DROP INDEX IF EXISTS idx_matilda_canonical_packages_draft_package_id;
    `);

    sqlite.exec(`
      ALTER TABLE matilda_canonical_packages
      RENAME TO matilda_canonical_packages_legacy_version_identity;
    `);

    createCanonicalPackageTable();

    sqlite.exec(`
      INSERT INTO matilda_canonical_packages (
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
      )
      SELECT
        package_id,
        1,
        summary_id,
        draft_package_id,
        NULL,
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
      FROM matilda_canonical_packages_legacy_version_identity;
    `);

    sqlite.exec(`
      DROP TABLE matilda_canonical_packages_legacy_version_identity;
    `);
  })();
}

export function initializeCanonicalPackageSchema() {
  initializeDraftRevisionSchema();

  migrateLegacyCanonicalPackageTableIfRequired();

  sqlite.exec(`
    CREATE UNIQUE INDEX IF NOT EXISTS
      idx_matilda_canonical_packages_draft_revision_id
    ON matilda_canonical_packages (draft_revision_id)
    WHERE draft_revision_id IS NOT NULL;
  `);

  sqlite.exec(`
    CREATE INDEX IF NOT EXISTS
      idx_matilda_canonical_packages_draft_package_version
    ON matilda_canonical_packages (
      draft_package_id,
      package_version
    );
  `);

  sqlite.exec(`
    CREATE INDEX IF NOT EXISTS
      idx_matilda_canonical_packages_lineage_version
    ON matilda_canonical_packages (
      lineage_id,
      package_version
    );
  `);
}

export function createCanonicalPackageFromApprovedSummary(
  {
    draft_revision_id,
    approval_actor,
  }: {
    draft_revision_id: string;
    approval_actor: string;
  },
  { schemaReady }: { schemaReady: boolean },
) {
  if (!schemaReady) {
    throw new CanonicalPackageSchemaUnavailableError();
  }

  if (
    typeof draft_revision_id !== "string"
    || draft_revision_id.trim().length === 0
  ) {
    throw new Error("draft_revision_id is required");
  }

  const normalizedDraftRevisionId = draft_revision_id.trim();

  const alreadyCanonicalized = sqlite
    .prepare(`
      SELECT
        package_id,
        package_version
      FROM matilda_canonical_packages
      WHERE draft_revision_id = ?
      LIMIT 1
    `)
    .get(normalizedDraftRevisionId) as
      | {
          package_id: string;
          package_version: number;
        }
      | undefined;

  if (alreadyCanonicalized) {
    throw new Error(
      `Draft Revision "${normalizedDraftRevisionId}" already produced Canonical Package `
      + `"${alreadyCanonicalized.package_id}" version ${alreadyCanonicalized.package_version}.`,
    );
  }

  const summary = generateReconciledIntentSummary({
    draft_revision_id: normalizedDraftRevisionId,
  });

  if (summary.approval_required !== true) {
    throw new Error("Summary is not eligible for approval.");
  }

  if (!summary.draft_revision_id) {
    throw new Error(
      "Canonical Package creation requires immutable Draft Revision provenance.",
    );
  }

  if (
    typeof summary.expected_outcome !== "string"
    || summary.expected_outcome.trim().length === 0
  ) {
    throw new Error(
      "Canonical Package approval requires a non-empty expected_outcome.",
    );
  }

  const latest = sqlite
    .prepare(`
      SELECT
        package_id,
        package_version,
        lineage_id,
        draft_package_id
      FROM matilda_canonical_packages
      WHERE draft_package_id = ?
        AND lineage_id = ?
      ORDER BY package_version DESC
      LIMIT 1
    `)
    .get(
      summary.draft_package_id,
      summary.lineage_id,
    ) as
      | {
          package_id: string;
          package_version: number;
          lineage_id: string;
          draft_package_id: string;
        }
      | undefined;

  const package_id =
    latest?.package_id ?? `pkg-${randomUUID()}`;

  const package_version =
    latest ? latest.package_version + 1 : 1;

  const created_at = new Date().toISOString();

  const persistCanonicalPackageAndProjection = sqlite.transaction(() => {
    try {
      sqlite
        .prepare(`
          INSERT INTO matilda_canonical_packages (
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
          ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        `)
        .run(
          package_id,
          package_version,
          summary.summary_id,
          summary.draft_package_id,
          summary.draft_revision_id,
          summary.lineage_id,
          summary.project_id,
          summary.conversation_id,
          summary.interpreted_objective,
          summary.proposed_work,
          summary.proposed_artifacts,
          summary.in_scope,
          summary.constraints,
          summary.expected_outcome,
          approval_actor,
          created_at,
          "canonical_approved",
          created_at,
        );
    } catch (err) {
      if (
        err instanceof Error
        && /UNIQUE constraint failed/i.test(err.message)
      ) {
        throw new Error(
          "Canonical Package version identity or Draft Revision provenance already exists.",
        );
      }

      throw err;
    }

    projectCanonicalPackageToMissionPackage(
      sqlite,
      {
        project_id: summary.project_id,
        package_id,
        package_version,
      },
    );
  });

  persistCanonicalPackageAndProjection();

  return {
    package_id,
    package_version,
    summary_id: summary.summary_id,
    draft_package_id: summary.draft_package_id,
    draft_revision_id: summary.draft_revision_id,
    lineage_id: summary.lineage_id,
    project_id: summary.project_id,
    conversation_id: summary.conversation_id,
    approved_interpretation: summary.interpreted_objective,
    approved_work: summary.proposed_work,
    approved_artifacts: summary.proposed_artifacts,
    approved_scope: summary.in_scope,
    approved_constraints: summary.constraints,
    approved_expected_outcome: summary.expected_outcome,
    approval_actor,
    approval_timestamp: created_at,
    status: "canonical_approved",
    created_at,
    delegation_authorized: false,
    validation_authorized: false,
    envelope_authorized: false,
    execution_authorized: false,
  };
}
