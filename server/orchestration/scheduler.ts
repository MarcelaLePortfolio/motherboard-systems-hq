import type { PolicyContext } from "./policy";

export type SchedulerTask = {
  id: string;
  kind: string;
  priority: number;
  state: "QUEUED" | "ROUTED" | "RUNNING" | "WAITING" | "RETRY_WAIT";
  nextEligibleAt?: number | null; // used for RETRY_WAIT or delayed queueing
  assignedAgent?: string | null;
};

export type ThrottleConfig = {
  globalMaxRunning: number;          // cap total running tasks
  perAgentMaxRunning: number;        // cap running per agent
  perKindMaxRunning: number;         // cap running per kind
  backoffBaseMs: number;             // base retry delay
  backoffMaxMs: number;              // max retry delay
  jitterPct: number;                 // 0..1 (e.g., 0.2 = ±20%)
};

export type RunningSnapshot = {
  runningTotal: number;
  runningByAgent: Map<string, number>;
  runningByKind: Map<string, number>;
};

export type Eligibility =
  | { ok: true; eligible: true; reason: string }
  | { ok: true; eligible: false; reason: string }
  | { ok: false; eligible: false; reason: string };

export function computeBackoffMs(baseMs: number, maxMs: number, attempt: number): number {
  // attempt starts at 1 for first retry
  const exp = Math.max(1, attempt);
  const ms = baseMs * Math.pow(2, exp - 1);
  return Math.min(maxMs, Math.floor(ms));
}

export function applyJitter(ms: number, jitterPct: number, rand01: number): number {
  const j = Math.max(0, Math.min(1, jitterPct));
  const r = Math.max(0, Math.min(1, rand01));
  const delta = ms * j;
  // map r in [0,1] to [-delta, +delta]
  const signed = (r * 2 - 1) * delta;
  return Math.max(0, Math.floor(ms + signed));
}

export function isEligibleNow(ctx: PolicyContext, task: SchedulerTask, snap: RunningSnapshot, cfg: ThrottleConfig): Eligibility {
  if (ctx.operatorMode === "PAUSE") return { ok: true, eligible: false, reason: "operatorMode=PAUSE" };
  if (ctx.operatorMode === "DRAIN") return { ok: true, eligible: false, reason: "operatorMode=DRAIN (no new starts)" };

  if (task.nextEligibleAt != null && task.nextEligibleAt > ctx.now) {
    return { ok: true, eligible: false, reason: `not_before=${task.nextEligibleAt}` };
  }

  if (snap.runningTotal >= cfg.globalMaxRunning) {
    return { ok: true, eligible: false, reason: "global cap reached" };
  }

  const agent = task.assignedAgent || "unassigned";
  const aCount = snap.runningByAgent.get(agent) || 0;
  if (aCount >= cfg.perAgentMaxRunning) {
    return { ok: true, eligible: false, reason: `agent cap reached agent=${agent}` };
  }

  const kCount = snap.runningByKind.get(task.kind) || 0;
  if (kCount >= cfg.perKindMaxRunning) {
    return { ok: true, eligible: false, reason: `kind cap reached kind=${task.kind}` };
  }

  return { ok: true, eligible: true, reason: "eligible" };
}
