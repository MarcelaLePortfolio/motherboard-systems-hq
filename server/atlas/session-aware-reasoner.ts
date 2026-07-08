
import { EventSession } from "./session-cluster";

import { buildCausalGraph } from "./causal-graph";

import { pruneCausalGraph } from "./causal-prune";

export type SessionExplanation = {

  sessionId: string;

  summary: string;

  causalChain: string[];

  dominantSignals: string[];

};

/**

 * Converts sessions into high-level causal explanations

 */

export function reasonOverSessions(

  sessions: EventSession[]

): SessionExplanation[] {

  return sessions.map(session => {

    const graph = buildCausalGraph(session.events);

    const pruned = pruneCausalGraph(graph);

    const causalChain = pruned.map((n: any, i: number) =>

      `${i + 1}. ${n.type} → ${n.file ?? "unknown"} (w=${n.weight})`

    );

    const dominantSignals = Array.from(

      new Set(session.events.map(e => e.action))

    );

    const summary =

      `Session over ${session.events.length} events ` +

      `centered on '${session.dominantAction}' affecting ` +

      `${session.dominantFile ?? "multiple targets"}`;

    return {

      sessionId: session.id,

      summary,

      causalChain,

      dominantSignals

    };

  });

}

