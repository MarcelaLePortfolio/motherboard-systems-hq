
import { emitEvent } from "../events/execution-event-bus";

export function recordExecutionEvent(event: {

  action: string;

  input?: any;

  output?: any;

  affectedFiles?: string[];

}) {

  emitEvent({

    id: crypto.randomUUID(),

    action: event.action,

    timestamp: Date.now(),

    input: event.input,

    output: event.output,

    affectedFiles: event.affectedFiles

  });

}

