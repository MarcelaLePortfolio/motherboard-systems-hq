import test from "node:test";
import assert from "node:assert/strict";
import { computeBackoffMs, applyJitter, isEligibleNow, type SchedulerTask, type RunningSnapshot, type ThrottleConfig } from "./scheduler";
import type { PolicyContext } from "./policy";

const cfg: ThrottleConfig = {
  globalMaxRunning: 2,
  perAgentMaxRunning: 1,
  perKindMaxRunning: 1,
  backoffBaseMs: 1000,
  backoffMaxMs: 8000,
  jitterPct: 0.2,
};

function snap(runningTotal: number, byAgent: [string, number][], byKind: [string, number][]): RunningSnapshot {
  return {
    runningTotal,
    runningByAgent: new Map(byAgent),
    runningByKind: new Map(byKind),
  };
}

const ctxNormal: PolicyContext = { now: 100, operatorMode: "NORMAL", intent: null };
const ctxPause: PolicyContext = { now: 100, operatorMode: "PAUSE", intent: null };

function task(overrides: Partial<SchedulerTask> = {}): SchedulerTask {
  return {
    id: "t1",
    kind: "demo",
    priority: 50,
    state: "QUEUED",
    nextEligibleAt: null,
    assignedAgent: "cade",
    ...overrides,
  };
}

test("backoff grows exponentially with cap", () => {
  assert.equal(computeBackoffMs(1000, 8000, 1), 1000);
  assert.equal(computeBackoffMs(1000, 8000, 2), 2000);
  assert.equal(computeBackoffMs(1000, 8000, 3), 4000);
  assert.equal(computeBackoffMs(1000, 8000, 4), 8000);
  assert.equal(computeBackoffMs(1000, 8000, 5), 8000);
});

test("jitter applies +/- percent bounds", () => {
  const base = 1000;
  // rand01=0 => -delta; rand01=1 => +delta
  const low = applyJitter(base, 0.2, 0);
  const high = applyJitter(base, 0.2, 1);
  assert.ok(low >= 800 && low <= 1000);
  assert.ok(high >= 1000 && high <= 1200);
});

test("eligibility: blocked by PAUSE", () => {
  const r = isEligibleNow(ctxPause, task(), snap(0, [], []), cfg);
  assert.equal(r.ok, true);
  assert.equal(r.eligible, false);
});

test("eligibility: blocked by not_before", () => {
  const r = isEligibleNow(ctxNormal, task({ nextEligibleAt: 999 }), snap(0, [], []), cfg);
  assert.equal(r.ok, true);
  assert.equal(r.eligible, false);
});

test("eligibility: blocked by global cap", () => {
  const r = isEligibleNow(ctxNormal, task(), snap(2, [["cade", 0]], [["demo", 0]]), cfg);
  assert.equal(r.ok, true);
  assert.equal(r.eligible, false);
});

test("eligibility: blocked by agent cap", () => {
  const r = isEligibleNow(ctxNormal, task({ assignedAgent: "cade" }), snap(0, [["cade", 1]], [["demo", 0]]), cfg);
  assert.equal(r.ok, true);
  assert.equal(r.eligible, false);
});

test("eligibility: blocked by kind cap", () => {
  const r = isEligibleNow(ctxNormal, task({ kind: "demo" }), snap(0, [["cade", 0]], [["demo", 1]]), cfg);
  assert.equal(r.ok, true);
  assert.equal(r.eligible, false);
});

test("eligibility: eligible when under caps", () => {
  const r = isEligibleNow(ctxNormal, task(), snap(0, [["cade", 0]], [["demo", 0]]), cfg);
  assert.equal(r.ok, true);
  assert.equal(r.eligible, true);
});
