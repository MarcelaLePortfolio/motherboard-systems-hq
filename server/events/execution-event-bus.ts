
/**

 * Execution Event Bus (single source of truth for Atlas)

 */

export type ExecutionEvent = {

  id: string;

  action: string;

  timestamp: number;

  input?: any;

  output?: any;

  affectedFiles?: string[];

};

const eventLog: ExecutionEvent[] = [];

export function emitEvent(event: ExecutionEvent) {

  eventLog.push(event);

}

export function getEvents(): ExecutionEvent[] {

  return eventLog;

}

export function clearEvents() {

  eventLog.length = 0;

}

