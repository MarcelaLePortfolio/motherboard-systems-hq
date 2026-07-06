
import { randomUUID } from "crypto";

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

  const confirmation_id = `confirmation-${randomUUID()}`;

  const created_at = new Date().toISOString();

  return {

    confirmation_id,

    preview_id,

    execution_plan_id,

    package_id,

    lineage_id,

    confirmation_actor,

    confirmation_timestamp: created_at,

    confirmation_result: "confirmed",

    status: "preview_confirmed",

    created_at,

    execution_authorized: false,

  };

}

