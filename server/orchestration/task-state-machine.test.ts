import test from "node:test";
import assert from "node:assert/strict";
import { canTransition, reduceTask, type Task } from "./task-state-machine";

function baseTask(): Task {
  const now = Date.now();
  return {
    id: "t1",
    kind: "demo",
    createdAt: now,
    updatedAt: now,
    state: "DRAFT",
    priority: 50,
    attempts: 0,
    maxAttempts: 3,
    dependsOn: [],
    payload: {},
    lastError: null,
  };
}

test("canTransition allows DRAFT -> QUEUED", () => {
  assert.equal(canTransition("DRAFT", "QUEUED"), true);
});

test("reduceTask queues from DRAFT", () => {
  const t = baseTask();
  const r = reduceTask(t, { type: "task.queue", ts: t.updatedAt + 1 });
  assert.equal(r.ok, true);
  if (r.ok) assert.equal(r.task.state, "QUEUED");
});

test("reduceTask blocks illegal transition", () => {
  const t = { ...baseTask(), state: "DRAFT" as const };
  const r = reduceTask(t, { type: "task.start", ts: t.updatedAt + 1 });
  assert.equal(r.ok, false);
});
