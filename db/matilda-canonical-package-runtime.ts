import { randomUUID } from "node:crypto";

import Database from "better-sqlite3";

import { generateReconciledIntentSummary } from "./matilda-reconciled-intent-runtime";

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

export function initializeCanonicalPackageSchema() {
  sqlite.exec(`
    CREATE TABLE IF NOT EXISTS matilda_canonical_packages (
      package_id TEXT PRIMARY KEY,
      summary_id TEXT NOT NULL,
      draft_package_id TEXT NOT NULL,
      lineage_id TEXT NOT NULL,
      approved_interpretation TEXT NOT NULL,
      approved_work TEXT,
      approved_artifacts TEXT,
      approved_scope TEXT,
      approved_constraints TEXT,
      approved_expected_outcome TEXT,
      approval_actor TEXT NOT NULL,
      approval_timestamp TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  `);

  const columns = sqlite
    .prepare("PRAGMA table_info(matilda_canonical_packages)")
    .all() as Array<{ name: string }>;

  if (!columns.some((column) => column.name === "project_id")) {
    sqlite.exec(`
      ALTER TABLE matilda_canonical_packages
      ADD COLUMN project_id TEXT;
    `);
  }

  if (!columns.some((column) => column.name === "conversation_id")) {
    sqlite.exec(`
      ALTER TABLE matilda_canonical_packages
      ADD COLUMN conversation_id TEXT;
    `);
  }

  try {
    sqlite.exec(`
      CREATE UNIQUE INDEX IF NOT EXISTS
        idx_matilda_canonical_packages_draft_package_id
      ON matilda_canonical_packages (draft_package_id);
    `);
  } catch (err) {
    throw new Error(
      "Unable to enforce one Canonical Package per draft_package_id: " +
        "matilda_canonical_packages already contains duplicate draft_package_id rows, " +
        "so the unique index could not be created. This must be resolved with an explicit, " +
        "manually-reviewed data migration before Canonical Package creation can proceed safely. " +
        `(${err instanceof Error ? err.message : String(err)})`,
    );
  }
}

export function createCanonicalPackageFromApprovedSummary(
  {
    draft_package_id,
    approval_actor,
  }: {
    draft_package_id: string;
    approval_actor: string;
  },
  { schemaReady }: { schemaReady: boolean },
) {
  if (!schemaReady) {
    throw new CanonicalPackageSchemaUnavailableError();
  }

  const existing = sqlite
    .prepare(
      "SELECT package_id FROM matilda_canonical_packages WHERE draft_package_id = ?",
    )
    .get(draft_package_id) as { package_id: string } | undefined;

  if (existing) {
    throw new Error(
      `Canonical Package already exists for draft_package_id "${draft_package_id}" (package_id: ${existing.package_id}). Only one Canonical Package is permitted per Living Draft Package.`,
    );
  }

  const summary = generateReconciledIntentSummary({ draft_package_id });

  if (summary.approval_required !== true) {
    throw new Error("Summary is not eligible for approval.");
  }

  const created_at = new Date().toISOString();
  const package_id = `pkg-${randomUUID()}`;

  try {
    sqlite
      .prepare(`
        INSERT INTO matilda_canonical_packages (
          package_id,
          summary_id,
          draft_package_id,
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
        ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
      `)
      .run(
        package_id,
        summary.summary_id,
        summary.draft_package_id,
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
    if (err instanceof Error && /UNIQUE constraint failed/i.test(err.message)) {
      throw new Error(
        `Canonical Package already exists for draft_package_id "${draft_package_id}". Only one Canonical Package is permitted per Living Draft Package.`,
      );
    }

    throw err;
  }

  return {
    package_id,
    summary_id: summary.summary_id,
    draft_package_id: summary.draft_package_id,
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
