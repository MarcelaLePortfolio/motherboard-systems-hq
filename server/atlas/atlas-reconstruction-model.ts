
/**

 * Atlas Reconstruction Model v1

 *

 * Purpose:

 * Reconstruct "why" from execution history, not from execution agents.

 */

export type ExecutionEvent = {

  action: string;

  timestamp: number;

  input?: any;

  output?: any;

  affectedFiles?: string[];

};

export type SystemStateSnapshot = {

  before: Record<string, any>;

  after: Record<string, any>;

};

export type AtlasExplanation = {

  why: string;

  confidence: number;

  supportingEvents: ExecutionEvent[];

};

export function reconstructWhy(

  intent: any,

  events: ExecutionEvent[],

  state: SystemStateSnapshot

): AtlasExplanation {

  const lastEvent = events[events.length - 1];

  const why =

    `Action '${lastEvent?.action}' aligns with intent and produced a state change.`;

  return {

    why,

    confidence: 0.6,

    supportingEvents: events

  };

}

