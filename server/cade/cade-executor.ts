
import { recordExecutionEvent } from "./cade-event-wrapper";

export type CadeAction =

  | "create_file"

  | "update_file"

  | "delete_file";

export async function executeCadeAction(input: {

  action: CadeAction;

  payload: any;

}) {

  // minimal simulation layer for now

  let result;

  if (input.action === "create_file") {

    result = {

      status: "ok",

      file: input.payload?.filename ?? "unknown"

    };

  }

  if (input.action === "update_file") {

    result = {

      status: "ok",

      updated: input.payload?.filename ?? "unknown"

    };

  }

  if (input.action === "delete_file") {

    result = {

      status: "ok",

      deleted: input.payload?.filename ?? "unknown"

    };

  }

  recordExecutionEvent({

    action: input.action,

    input: input.payload,

    output: result,

    affectedFiles: input.payload?.filename ? [input.payload.filename] : []

  });

  return result;

}

