import { randomUUID } from "crypto";
import Database from "better-sqlite3";

import { loadExecutionPlan } from "./matilda-execution-planning-runtime.js";
import { loadPreview } from "./matilda-preview-runtime.js";

const db = new Database("db/main.db");

export type MatildaPreviewConfirmation = {
  confirmation_id: string;
  preview_id: string;
  execution_plan_id: string;
  package_id: string;
  lineage_id: string;
  confirmation_actor: string;
  confirmation_timestamp: string;
  confirmation_result: "confirmed";
  status: "preview_confirmed";
  created_at: string;
  execution_authorized: false;
};

function ensurePreviewConfirmationSchema(): void {
  db.exec(`
    CREATE TABLE IF NOT EXISTS matilda_preview_confirmations (
      confirmation_id TEXT PRIMARY KEY,
      preview_id TEXT NOT NULL UNIQUE,
      execution_plan_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      lineage_id TEXT NOT NULL,
      confirmation_actor TEXT NOT NULL,
      confirmation_timestamp TEXT NOT NULL,
      confirmation_result TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_matilda_preview_confirmations_provenance
    ON matilda_preview_confirmations (
      execution_plan_id,
      package_id,
      lineage_id
    );
  `);
}

export function loadPreviewConfirmation(
  confirmation_id: string,
): MatildaPreviewConfirmation | null {
  ensurePreviewConfirmationSchema();

  const row = db.prepare(`
    SELECT
      confirmation_id,
      preview_id,
      execution_plan_id,
      package_id,
      lineage_id,
      confirmation_actor,
      confirmation_timestamp,
      confirmation_result,
      status,
      created_at
    FROM matilda_preview_confirmations
    WHERE confirmation_id = ?
  `).get(confirmation_id) as Omit<
    MatildaPreviewConfirmation,
    "execution_authorized"
  > | undefined;

  if (!row) {
    return null;
  }

  if (
    row.confirmation_result !== "confirmed"
    || row.status !== "preview_confirmed"
  ) {
    throw new Error(
      "Persisted preview confirmation is not in a confirmed state.",
    );
  }

  return {
    ...row,
    confirmation_result: "confirmed",
    status: "preview_confirmed",
    execution_authorized: false,
  };
}

export function createPreviewConfirmation({
  preview_id,
  execution_plan_id,
  package_id,
  lineage_id,
  confirmation_actor,
}: {
  preview_id: string;
  execution_plan_id: string;
  package_id: string;
  lineage_id: string;
  confirmation_actor: string;
}): MatildaPreviewConfirmation {
  const preview = loadPreview(preview_id);

  if (!preview) {
    throw new Error("Preview evidence not found.");
  }

  const plan = loadExecutionPlan(execution_plan_id);

  if (!plan) {
    throw new Error("Execution plan evidence not found.");
  }

  if (
    preview.execution_plan_id !== execution_plan_id
    || preview.package_id !== package_id
    || preview.lineage_id !== lineage_id
  ) {
    throw new Error(
      "Preview confirmation provenance does not match persisted preview.",
    );
  }

  if (
    plan.execution_plan_id !== preview.execution_plan_id
    || plan.assignment_id !== preview.assignment_id
    || plan.package_id !== preview.package_id
    || plan.lineage_id !== preview.lineage_id
  ) {
    throw new Error(
      "Preview confirmation provenance does not match persisted execution plan.",
    );
  }

  ensurePreviewConfirmationSchema();

  const existing = db.prepare(`
    SELECT confirmation_id
    FROM matilda_preview_confirmations
    WHERE preview_id = ?
  `).get(preview.preview_id) as {
    confirmation_id: string;
  } | undefined;

  if (existing) {
    throw new Error(
      "Preview already has durable confirmation evidence.",
    );
  }

  const confirmation_id = `confirmation-${randomUUID()}`;
  const created_at = new Date().toISOString();

  const confirmation: MatildaPreviewConfirmation = {
    confirmation_id,
    preview_id: preview.preview_id,
    execution_plan_id: preview.execution_plan_id,
    package_id: preview.package_id,
    lineage_id: preview.lineage_id,
    confirmation_actor,
    confirmation_timestamp: created_at,
    confirmation_result: "confirmed",
    status: "preview_confirmed",
    created_at,
    execution_authorized: false,
  };

  db.prepare(`
    INSERT INTO matilda_preview_confirmations (
      confirmation_id,
      preview_id,
      execution_plan_id,
      package_id,
      lineage_id,
      confirmation_actor,
      confirmation_timestamp,
      confirmation_result,
      status,
      created_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    confirmation.confirmation_id,
    confirmation.preview_id,
    confirmation.execution_plan_id,
    confirmation.package_id,
    confirmation.lineage_id,
    confirmation.confirmation_actor,
    confirmation.confirmation_timestamp,
    confirmation.confirmation_result,
    confirmation.status,
    confirmation.created_at,
  );

  return confirmation;
}
