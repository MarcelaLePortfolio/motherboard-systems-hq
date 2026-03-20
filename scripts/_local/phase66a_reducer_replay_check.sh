#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "== Phase 66A.2 reducer replay check =="

node <<'NODE'
const fs = require("fs");
const vm = require("vm");

function loadReducer(path, extras = {}) {
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
    ...extras,
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

function assertEqual(actual, expected, label) {
  if (actual !== expected) {
    throw new Error(`${label}: expected ${expected}, got ${actual}`);
  }
}

const queueReducer = loadReducer("public/js/telemetry_queue_depth_reducer.js");
const failedReducer = loadReducer("public/js/telemetry_failed_tasks_reducer.js");

assertEqual(queueReducer.subscription.channel, "task-events", "queue reducer channel");
assertEqual(failedReducer.subscription.channel, "task-events", "failed reducer channel");

const queueEvents = [
  { task_id: "t1", state: "task.created", ts: 1 },
  { task_id: "t1", state: "task.queued", ts: 2 },
  { task_id: "t2", state: "task.created", ts: 3 },
  { task_id: "t1", state: "task.started", ts: 4 },
  { task_id: "t3", state: "task.queued", ts: 5 },
  { task_id: "t2", state: "task.failed", ts: 6 },
  { task_id: "t3", state: "task.cancelled", ts: 7 },
];

for (const ev of queueEvents) {
  queueReducer.subscription.fn(ev);
}

assertEqual(
  queueReducer.context.window.queueDepthTelemetry.getQueueDepth(),
  0,
  "queue depth after replay"
);

queueReducer.subscription.fn({ task_id: "ghost", state: "task.completed", ts: 8 });
assertEqual(
  queueReducer.context.window.queueDepthTelemetry.getQueueDepth(),
  0,
  "queue depth after orphan removal"
);

queueReducer.subscription.fn({ state: "task.created", ts: 9 });
assertEqual(
  queueReducer.context.window.queueDepthTelemetry.getQueueDepth(),
  0,
  "queue depth after malformed event"
);

const failedEvents = [
  { task_id: "f1", run_id: "r1", state: "task.failed", ts: 10 },
  { task_id: "f1", run_id: "r1", state: "task.failed", ts: 10 },
  { task_id: "f1", run_id: "r1", state: "task.failed", ts: 11 },
  { task_id: "f2", run_id: "r2", state: "task.completed", ts: 12 },
  { task_id: "f3", run_id: "r3", state: "task.failed", ts: 13 },
  { run_id: "r4", state: "task.failed", ts: 14 },
];

for (const ev of failedEvents) {
  failedReducer.subscription.fn(ev);
}

assertEqual(
  failedReducer.context.window.failedTasksTelemetry.getFailedTaskCount(),
  3,
  "failed task count after replay"
);

console.log("Reducer replay check PASS");
NODE

bash scripts/_local/phase65_pre_commit_protection_gate.sh

echo "== Phase 66A.2 reducer replay check PASSED =="
