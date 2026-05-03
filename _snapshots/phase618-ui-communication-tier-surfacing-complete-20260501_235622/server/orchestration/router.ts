import type { PolicyContext } from "./policy";

export type AgentId = "matilda" | "cade" | "effie" | "atlas" | "unknown";

export type AgentSnapshot = {
  id: AgentId;
  healthy: boolean;
  // simple capacity signal (Phase 17.3); scheduling/throttling lands in 17.4
  busy: boolean;
  caps: string[]; // capability tags
};

export type RouteRequest = {
  taskId: string;
  kind: string;
  requiredCaps?: string[];
};

export type RouteResult =
  | { ok: true; assignedAgent: AgentId; reason: string }
  | { ok: false; reason: string };

function hasAllCaps(agent: AgentSnapshot, required: string[]): boolean {
  const set = new Set(agent.caps || []);
  return required.every((c) => set.has(c));
}

/**
 * Routing rules (Phase 17.3, pure):
 * - If operatorMode is PAUSE or DRAIN, do not route (scheduler will handle later; return ok:false).
 * - Prefer first healthy, not-busy agent that satisfies requiredCaps.
 * - If none available, return ok:false.
 *
 * NOTE: Kind->caps mapping stays external for now; caller provides requiredCaps.
 */
export function routeTask(ctx: PolicyContext, req: RouteRequest, agents: AgentSnapshot[]): RouteResult {
  if (ctx.operatorMode === "PAUSE" || ctx.operatorMode === "DRAIN") {
    return { ok: false, reason: `operatorMode=${ctx.operatorMode} blocks routing` };
  }

  const required = req.requiredCaps || [];

  const candidates = agents
    .filter((a) => a.healthy)
    .filter((a) => !a.busy)
    .filter((a) => hasAllCaps(a, required));

  if (candidates.length === 0) {
    return { ok: false, reason: `no available agent for caps=[${required.join(",")}] kind=${req.kind}` };
  }

  // deterministic: stable order (caller controls ordering)
  const chosen = candidates[0];
  return { ok: true, assignedAgent: chosen.id, reason: `chosen=${chosen.id} caps_ok kind=${req.kind}` };
}
