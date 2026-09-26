import { randomUUID } from "crypto";
import Database from "better-sqlite3";

import { loadExecutionPlan } from "./matilda-execution-planning-runtime.js";

const db = new Database("db/main.db");

export type MatildaPreview = {
  preview_id: string;
  execution_plan_id: string;
  assignment_id: string;
  package_id: string;
  lineage_id: string;
  preview_summary: string;
  preview_steps: string[];
  preview_mutations: string[];
  rollback_references: string[];
  reconciliation_summary: string;
  status: "preview_ready";
  created_at: string;
  preview_confirmed: false;
  execution_authorized: false;
};

function ensurePreviewSchema(): void {
  db.exec(`
    CREATE TABLE IF NOT EXISTS matilda_previews (
      preview_id TEXT PRIMARY KEY,
      execution_plan_id TEXT NOT NULL,
      assignment_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      lineage_id TEXT NOT NULL,
      preview_json TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_matilda_previews_plan
      ON matilda_previews (execution_plan_id);

    CREATE INDEX IF NOT EXISTS idx_matilda_previews_package_lineage
      ON matilda_previews (package_id, lineage_id);
  `);
}

export function loadPreview(
  preview_id: string,
): MatildaPreview | null {
  ensurePreviewSchema();

  const row = db.prepare(`
    SELECT preview_json
    FROM matilda_previews
    WHERE preview_id = ?
    LIMIT 1
  `).get(preview_id) as { preview_json: string } | undefined;

  return row
    ? JSON.parse(row.preview_json) as MatildaPreview
    : null;
}

export function createPreview({
  execution_plan_id,
  assignment_id,
  package_id,
  lineage_id,
}: {
  execution_plan_id: string;
  assignment_id: string;
  package_id: string;
  lineage_id: string;
}): MatildaPreview {
  ensurePreviewSchema();

  const plan = loadExecutionPlan(execution_plan_id);

  if (!plan) {
    throw new Error("Execution plan evidence not found.");
  }

  if (
    plan.assignment_id !== assignment_id
    || plan.package_id !== package_id
    || plan.lineage_id !== lineage_id
  ) {
    throw new Error(
      "Preview provenance does not match persisted execution plan.",
    );
  }

  const preview_id = `preview-${randomUUID()}`;
  const created_at = new Date().toISOString();

  const preview: MatildaPreview = {
    preview_id,
    execution_plan_id,
    assignment_id,
    package_id,
    lineage_id,
    preview_summary:
      "User-visible deterministic preview generated from the approved dry-run execution plan.",
    preview_steps: [
      "Load dry-run execution plan.",
      "Render planned engineering sequence.",
      "Display planned mutations (read-only).",
      "Display rollback references.",
      "Prepare operator review surface.",
    ],
    preview_mutations: [
      "No mutations performed. Preview is read-only.",
    ],
    rollback_references: [
      "Current HEAD",
      "Latest DR checkpoint",
    ],
    reconciliation_summary:
      "Preview generated successfully. Awaiting explicit Preview Confirmation. No execution authority granted.",
    status: "preview_ready",
    created_at,
    preview_confirmed: false,
    execution_authorized: false,
  };

  db.prepare(`
    INSERT INTO matilda_previews (
      preview_id,
      execution_plan_id,
      assignment_id,
      package_id,
      lineage_id,
      preview_json,
      status,
      created_at
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    preview.preview_id,
    preview.execution_plan_id,
    preview.assignment_id,
    preview.package_id,
    preview.lineage_id,
    JSON.stringify(preview),
    preview.status,
    preview.created_at,
  );

  return preview;
}
