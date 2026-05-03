import type { OrchestrationEvent, Policy, PolicyContext, PolicyDecision } from "./policy";

export type PipelineResult = {
  ctx: PolicyContext;
  decisions: PolicyDecision[];
  emitted: OrchestrationEvent[];
};

export function applyDecisions(ctx: PolicyContext, decisions: PolicyDecision[]): { ctx: PolicyContext; emitted: OrchestrationEvent[] } {
  let next = { ...ctx };
  const emitted: OrchestrationEvent[] = [];

  for (const d of decisions) {
    switch (d.kind) {
      case "noop":
        break;
      case "emit":
        emitted.push(...d.events);
        break;
      case "set_mode":
        next.operatorMode = d.mode;
        break;
      case "set_intent":
        next.intent = d.intent;
        break;
      default: {
        const _exhaustive: never = d;
        throw new Error(`unknown decision ${(d as any).kind}`);
      }
    }
  }

  return { ctx: next, emitted };
}

export function runPolicyPipeline(ctx: PolicyContext, ev: OrchestrationEvent, policies: Policy[]): PipelineResult {
  const all: PolicyDecision[] = [];
  for (const p of policies) {
    const out = p.apply(ctx, ev) || [];
    all.push(...out);
  }

  const applied = applyDecisions(ctx, all);

  return {
    ctx: applied.ctx,
    decisions: all,
    emitted: applied.emitted,
  };
}

export function runEventLoopOnce(ctx: PolicyContext, events: OrchestrationEvent[], policies: Policy[]): {
  ctx: PolicyContext;
  processed: OrchestrationEvent[];
  emitted: OrchestrationEvent[];
} {
  const processed: OrchestrationEvent[] = [];
  const emitted: OrchestrationEvent[] = [];

  for (const ev of events) {
    processed.push(ev);
    const r = runPolicyPipeline(ctx, ev, policies);
    ctx = r.ctx;
    emitted.push(...r.emitted);
  }

  return { ctx, processed, emitted };
}
