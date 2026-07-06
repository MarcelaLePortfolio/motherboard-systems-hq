
import { randomUUID } from "node:crypto";

export function createExecutionAuthorization({

  confirmation_id,

  preview_id,

  execution_plan_id,

  package_id,

  lineage_id,

  authorization_actor,

}: {

  confirmation_id: string;

  preview_id: string;

  execution_plan_id: string;

  package_id: string;

  lineage_id: string;

  authorization_actor: string;

}) {

  const authorization_id = `authorization-${randomUUID()}`;

  const created_at = new Date().toISOString();

  return {

    authorization_id,

    confirmation_id,

    preview_id,

    execution_plan_id,

    package_id,

    lineage_id,

    authorization_actor,

    authorization_timestamp: created_at,

    authorization_result: "authorized",

    status: "execution_authorized",

    created_at,

    cade_execution_started: false,

  };

}

