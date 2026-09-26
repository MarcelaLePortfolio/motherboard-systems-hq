import { randomUUID } from "crypto";

import { loadExecutionPlan } from "./matilda-execution-planning-runtime.js";
import { loadPreview } from "./matilda-preview-runtime.js";

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
}) {
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

  const confirmation_id = `confirmation-${randomUUID()}`;
  const created_at = new Date().toISOString();

  return {
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
}
