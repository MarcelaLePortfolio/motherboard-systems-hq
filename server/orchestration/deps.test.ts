import test from "node:test";
import assert from "node:assert/strict";
import { resolveDependencies, isRunnable, type TaskLike } from "./deps";

function t(id: string, state: string, dependsOn: string[] = []): TaskLike {
  return { id, state, dependsOn };
}

test("deps: runnable when no dependsOn", () => {
  const task = t("a", "QUEUED", []);
  const byId = new Map<string, TaskLike>([["a", task]]);
  const r = isRunnable(task, byId);
  assert.equal(r.runnable, true);
  assert.deepEqual(r.blockedBy, []);
});

test("deps: blocks when dependency missing", () => {
  const task = t("a", "QUEUED", ["b"]);
  const byId = new Map<string, TaskLike>([["a", task]]);
  const r = isRunnable(task, byId);
  assert.equal(r.runnable, false);
  assert.deepEqual(r.blockedBy, ["b"]);
});

test("deps: blocks until dependency SUCCEEDED", () => {
  const task = t("a", "QUEUED", ["b"]);
  const dep = t("b", "RUNNING", []);
  const byId = new Map<string, TaskLike>([
    ["a", task],
    ["b", dep],
  ]);
  const r = isRunnable(task, byId);
  assert.equal(r.runnable, false);
  assert.deepEqual(r.blockedBy, ["b"]);
});

test("deps: fails when dependency FAILED", () => {
  const task = t("a", "QUEUED", ["b"]);
  const dep = t("b", "FAILED", []);
  const byId = new Map<string, TaskLike>([
    ["a", task],
    ["b", dep],
  ]);
  const r = resolveDependencies(task, byId);
  assert.equal(r.ok, false);
  assert.match((r as any).error, /terminal FAILED/);
});
