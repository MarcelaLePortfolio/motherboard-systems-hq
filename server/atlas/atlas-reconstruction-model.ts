
import { ExecutionEvent } from "../events/execution-event-bus";

import { buildCausalGraph } from "./causal-graph";

import { pruneCausalGraph } from "./causal-prune";

export type AtlasExplanation = {

  summary: string;

  causalChain: string[];

  confidence: number;

  graph: any[];

};

function computeConfidence(graph: any[]) {

  if (!graph.length) return 0;

  const total = graph.reduce((sum: number, n: any) => {

    return sum + (n.weight ?? 0);

  }, 0);

  return Math.min(1, total / Math.max(graph.length, 1));

}

export function reconstructWhy(

  intent: any,

  events: ExecutionEvent[]

): AtlasExplanation {

  if (!events || events.length === 0) {

    return {

      summary: "No execution history available",

      causalChain: [],

      confidence: 0,

      graph: []

    };

  }

  const rawGraph = buildCausalGraph(events);

  const graph = pruneCausalGraph(rawGraph);

  const causalChain = graph.map((n: any, i: number) =>

    `${i + 1}. ${n.type} → ${n.file ?? "unknown"} (w=${n.weight})`

  );

  const last = graph[graph.length - 1];

  return {

    summary: `Pruned causal reasoning complete. Nodes=${graph.length}. Strongest=${last?.type ?? "none"}`,

    causalChain,

    confidence: computeConfidence(graph),

    graph

  };

}

