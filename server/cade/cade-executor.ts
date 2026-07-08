
import { recordExecutionEvent } from "./cade-event-wrapper";

import { createFile, updateFile, deleteFile } from "./cade-effects";

export type CadeAction =

  | "create_file"

  | "update_file"

  | "delete_file";

export async function executeCadeAction(input: {

  action: CadeAction;

  payload: any;

  executionId?: string;

}) {

  if (!input?.action) {

    return { status: "error", error: "missing_action" };

  }

  let result: any;

  if (input.action === "create_file") {

    const file = createFile(input.payload.filename, input.payload.content);

    result = { status: "ok", file };

  }

  else if (input.action === "update_file") {

    const file = updateFile(input.payload.filename, input.payload.content);

    result = { status: "ok", file };

  }

  else if (input.action === "delete_file") {

    const file = deleteFile(input.payload.filename);

    result = { status: "ok", file };

  }

  else {

    result = {

      status: "error",

      error: "unknown_action"

    };

  }

  recordExecutionEvent({

    id: input.executionId || crypto.randomUUID(),

    action: input.action,

    input: input.payload,

    output: result,

    affectedFiles: input.payload?.filename ? [input.payload.filename] : []

  });

  return result;

}

