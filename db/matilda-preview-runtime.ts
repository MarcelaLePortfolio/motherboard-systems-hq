
import { randomUUID } from "crypto";

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

}) {

  const preview_id = `preview-${randomUUID()}`;

  const created_at = new Date().toISOString();

  const preview_steps = [

    "Load dry-run execution plan.",

    "Render planned engineering sequence.",

    "Display planned mutations (read-only).",

    "Display rollback references.",

    "Prepare operator review surface.",

  ];

  const preview_mutations = [

    "No mutations performed. Preview is read-only.",

  ];

  const rollback_references = [

    "Current HEAD",

    "Latest DR checkpoint",

  ];

  const reconciliation_summary =

    "Preview generated successfully. Awaiting explicit Preview Confirmation. No execution authority granted.";

  const preview_summary =

    "User-visible deterministic preview generated from the approved dry-run execution plan.";

  return {

    preview_id,

    execution_plan_id,

    assignment_id,

    package_id,

    lineage_id,

    preview_summary,

    preview_steps,

    preview_mutations,

    rollback_references,

    reconciliation_summary,

    status: "preview_ready",

    created_at,

    preview_confirmed: false,

    execution_authorized: false,

  };

}

