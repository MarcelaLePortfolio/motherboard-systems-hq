
import { ExecutionEvent } from "../events/execution-event-bus";

import { applyTemporalDecay } from "./temporal-decay";

import { buildCausalGraph } from "./causal-graph";

import { pruneCausalGraph } from "./causal-prune";

import { clusterSessions } from "./session-cluster";

import { reasonOverSessions } from "./session-aware-reasoner";

/**

 * Unified Atlas Intelligence Engine

 * Single entry point for full system reasoning

 */

export function runAtlasIntelligence(events: ExecutionEvent[]) {

  if (!events || events.length === 0) {

    return {

      summary: "No events available for analysis",

      sessions: [],

      reasoning: [],

      graph: []

    };

  }

  // 1. Temporal weighting

  const temporalEvents = applyTemporalDecay(events);

  // 2. Causal graph

  const graph = buildCausalGraph(temporalEvents);

  // 3. Prune weak signals

  const prunedGraph = pruneCausalGraph(graph);

  // 4. Session clustering

  const sessions = clusterSessions(temporalEvents);

  // 5. Session reasoning layer

  const sessionReasoning = reasonOverSessions(sessions);

  // 6. Global summary signal

  const dominantActions = events.map(e => e.action);

  const uniqueActions = new Set(dominantActions).size;

  return {

    summary: `Atlas processed ${events.length} events into ${sessions.length} sessions with ${uniqueActions} unique action types`,

    sessions,

    sessionReasoning,

    graph: prunedGraph

  };

}

