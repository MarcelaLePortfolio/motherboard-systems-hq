
import { ExecutionEvent } from "../events/execution-event-bus";

export type CausalNode = {

  id: string;

  type: string;

  timestamp: number;

  label: string;

  file?: string;

  weight?: number;

  temporalWeight?: number;

  finalWeight?: number;

  dependsOn?: string[];

};

function computeBaseWeight(current: ExecutionEvent, prev?: ExecutionEvent): number {

  if (!prev) return 1;

  if (

    current.affectedFiles?.[0] &&

    current.affectedFiles[0] === prev.affectedFiles?.[0]

  ) {

    return 0.95;

  }

  if (current.action === prev.action) {

    return 0.6;

  }

  return 0.3;

}

export function buildCausalGraph(

  events: ExecutionEvent[]

): CausalNode[] {

  const now = Date.now();

  return events.map((e, index) => {

    const prev = events[index - 1];

    const baseWeight = computeBaseWeight(e, prev);

    // temporal decay (newer = stronger)

    const age = now - e.timestamp;

    const temporalWeight = Math.pow(0.5, age / (1000 * 60 * 10));

    const finalWeight = baseWeight * temporalWeight;

    return {

      id: e.id,

      type: e.action,

      timestamp: e.timestamp,

      label: e.action,

      file: e.affectedFiles?.[0],

      weight: baseWeight,

      temporalWeight,

      finalWeight,

      dependsOn: index > 0 ? [prev.id] : []

    };

  });

}

