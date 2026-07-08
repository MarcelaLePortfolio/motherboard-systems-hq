
export type ExecutionEvent = {

  id: string;

  action: string;

  timestamp: number;

  input?: any;

  output?: any;

  affectedFiles?: string[];

};

/**

 * Backwards compatibility shim.

 * Events now live in persistent store.

 */

import { getPersistentEvents } from "./execution-event-store";

export function getEvents(): ExecutionEvent[] {

  return getPersistentEvents();

}

