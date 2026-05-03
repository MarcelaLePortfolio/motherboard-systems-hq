import test from "node:test";
import assert from "node:assert/strict";
import { routeTask, type AgentSnapshot } from "./router";
import type { PolicyContext } from "./policy";

const ctxNormal: PolicyContext = { now: 1, operatorMode: "NORMAL", intent: null };
const ctxPause: PolicyContext = { now: 1, operatorMode: "PAUSE", intent: null };

function agent(id: AgentSnapshot["id"], healthy: boolean, busy: boolean, caps: string[]): AgentSnapshot {
  return { id, healthy, busy, caps };
}

test("router: blocks routing in PAUSE", () => {
  const r = routeTask(ctxPause, { taskId: "t1", kind: "demo", requiredCaps: [] }, [agent("cade", true, false, [])]);
  assert.equal(r.ok, false);
});

test("router: chooses first eligible healthy non-busy agent with caps", () => {
  const agents: AgentSnapshot[] = [
    agent("cade", true, true, ["db"]),
    agent("effie", true, false, ["local", "db"]),
    agent("atlas", true, false, ["planner"]),
  ];
  const r = routeTask(ctxNormal, { taskId: "t1", kind: "db_task", requiredCaps: ["db"] }, agents);
  assert.equal(r.ok, true);
  if (r.ok) assert.equal(r.assignedAgent, "effie");
});

test("router: fails if no agent satisfies caps", () => {
  const agents: AgentSnapshot[] = [agent("atlas", true, false, ["planner"])];
  const r = routeTask(ctxNormal, { taskId: "t1", kind: "db_task", requiredCaps: ["db"] }, agents);
  assert.equal(r.ok, false);
});
