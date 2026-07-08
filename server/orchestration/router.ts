
import type { PolicyContext } from "./policy";

import { executeCadeAction } from "../cade/cade-executor";

export type AgentId = "matilda" | "cade" | "effie" | "atlas" | "unknown";

export type AgentSnapshot = {

  id: AgentId;

  healthy: boolean;

  busy: boolean;

  caps: string[];

};

export type RouteRequest = {

  taskId: string;

  kind: string;

  requiredCaps?: string[];

  payload?: any;

  // NEW: execution capability flag (DEFAULT FALSE BEHAVIOR)

  execute?: boolean;

};

export type RouteResult =

  | { ok: true; assignedAgent: AgentId; reason: string; result?: any }

  | { ok: false; reason: string };

function hasAllCaps(agent: AgentSnapshot, required: string[]) {

  const set = new Set(agent.caps || []);

  return required.every((c) => set.has(c));

}

export async function routeTask(

  ctx: PolicyContext,

  req: RouteRequest,

  agents: AgentSnapshot[]

): Promise<RouteResult> {

  if (ctx.operatorMode === "PAUSE" || ctx.operatorMode === "DRAIN") {

    return { ok: false, reason: `operatorMode=${ctx.operatorMode} blocks routing` };

  }

  const required = req.requiredCaps || [];

  const candidates = agents

    .filter((a) => a.healthy)

    .filter((a) => !a.busy)

    .filter((a) => hasAllCaps(a, required));

  if (candidates.length === 0) {

    return {

      ok: false,

      reason: `no available agent for caps=[${required.join(",")}] kind=${req.kind}`

    };

  }

  const chosen = candidates[0];

  // IMPORTANT: execution gate exists but is NOT enabled by default usage

  if (req.execute === true && chosen.id === "cade") {

    const result = await executeCadeAction({

      action: req.kind as any,

      payload: req.payload

    });

    return {

      ok: true,

      assignedAgent: chosen.id,

      result,

      reason: `executed_by_cade kind=${req.kind}`

    };

  }

  return {

    ok: true,

    assignedAgent: chosen.id,

    reason: `routed_only chosen=${chosen.id} kind=${req.kind}`

  };

}

export default routeTask;

