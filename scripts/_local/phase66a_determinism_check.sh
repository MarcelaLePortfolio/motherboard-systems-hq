#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "== Phase 66A.3 determinism check =="

node <<'NODE'
const fs = require("fs");
const vm = require("vm");

function loadReducer(path) {
  const code = fs.readFileSync(path, "utf8");
  const subscriptions = [];
  const context = {
    console,
    Set,
    Map,
    window: {
      telemetryBus: {
        subscribe(channel, fn) {
          subscriptions.push({ channel, fn });
        },
      },
    },
  };

  vm.createContext(context);
  vm.runInContext(code, context, { filename: path });

  if (subscriptions.length !== 1) {
    throw new Error(`${path}: expected exactly one telemetry subscription, got ${subscriptions.length}`);
  }

  return {
    context,
    subscription: subscriptions[0],
  };
}

function runQueueScenario(events) {
  const reducer = loadReducer("public/js/telemetry_queue_depth_reducer.js");
  for (const ev of events) reducer.subscription.fn(ev);
  return reducer.context.window.queueDepthTelemetry.getQueueDepth();
}

function runFailedScenario(events) {
  const reducer = loadReducer("public/js/telemetry_failed_tasks_reducer.js");
  for (const ev of events) reducer.subscription.fn(ev);
  return reducer.context.window.failedTasksTelemetry.getFailedTaskCount();
}

function assertEqual(actual, expected, label) {
  if (actual !== expected) {
    throw new Error(`${label}: expected ${expected}, got ${actual}`);
  }
}

const queueEvents = [
  { task_id: "q1", state: "task.created", ts: 1 },
  { task_id: "q2", state: "task.queued", ts: 2 },
  { task_id: "q1", state: "task.started", ts: 3 },
  { task_id: "q2", state: "task.failed", ts: 4 },
  { task_id: "q3", state: "task.queued", ts: 5 },
  { task_id: "q3", state: "task.queued", ts: 5 },
  { task_id: "ghost", state: "task.completed", ts: 6 },
  { task_id: "q4", state: "task.created", ts: 7 },
];

const failedEvents = [
  { task_id: "f1", run_id: "r1", state: "task.failed", ts: 10 },
  { task_id: "f1", run_id: "r1", state: "task.failed", ts: 10 },
  { task_id: "f2", run_id: "r2", state: "task.failed", ts: 11 },
  { task_id: "f2", run_id: "r2", state: "task.failed", ts: 11 },
  { task_id: "f3", run_id: "r3", state: "task.completed", ts: 12 },
  { task_id: "f4", run_id: "r4", state: "task.failed", ts: 13 },
  { state: "task.failed", run_id: "bad", ts: 14 },
];

const queueRunA = runQueueScenario(queueEvents);
const queueRunB = runQueueScenario(queueEvents);
assertEqual(queueRunA, queueRunB, "queue reducer deterministic replay");
assertEqual(queueRunA, 2, "queue reducer expected final depth");

const failedRunA = runFailedScenario(failedEvents);
const failedRunB = runFailedScenario(failedEvents);
assertEqual(failedRunA, failedRunB, "failed reducer deterministic replay");
assertEqual(failedRunA, 3, "failed reducer expected final count");

console.log("Determinism check PASS");
NODE

bash scripts/_local/phase66a_reducer_replay_check.sh
bash scripts/_local/phase65_pre_commit_protection_gate.sh

echo "== Phase 66A.3 determinism check PASSED =="
