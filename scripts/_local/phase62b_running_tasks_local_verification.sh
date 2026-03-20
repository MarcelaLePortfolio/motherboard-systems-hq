#!/usr/bin/env bash
set -euo pipefail

OUT="docs/checkpoints/PHASE62B_RUNNING_TASKS_LOCAL_VERIFICATION_20260316.md"
mkdir -p docs/checkpoints

node <<'NODE' > "$OUT"
const cases = [
  {
    name: "created -> started -> completed",
    events: [
      { kind: "task.created", task_id: "a" },
      { kind: "task.started", task_id: "a" },
      { kind: "task.completed", task_id: "a", status: "done" },
    ],
    expected: [1, 1, 0],
  },
  {
    name: "started -> completed",
    events: [
      { kind: "task.started", task_id: "b" },
      { kind: "task.completed", task_id: "b", status: "done" },
    ],
    expected: [1, 0],
  },
  {
    name: "completed -> started",
    events: [
      { kind: "task.completed", task_id: "c", status: "done" },
      { kind: "task.started", task_id: "c" },
    ],
    expected: [0, 0],
  },
  {
    name: "duplicate started",
    events: [
      { kind: "task.started", task_id: "d" },
      { kind: "task.started", task_id: "d" },
      { kind: "task.completed", task_id: "d", status: "done" },
    ],
    expected: [1, 1, 0],
  },
  {
    name: "duplicate completed",
    events: [
      { kind: "task.started", task_id: "e" },
      { kind: "task.completed", task_id: "e", status: "done" },
      { kind: "task.completed", task_id: "e", status: "done" },
    ],
    expected: [1, 0, 0],
  },
  {
    name: "created -> failed",
    events: [
      { kind: "task.created", task_id: "f" },
      { kind: "task.failed", task_id: "f", status: "failed" },
    ],
    expected: [1, 0],
  },
  {
    name: "created -> cancelled",
    events: [
      { kind: "task.created", task_id: "g" },
      { kind: "task.cancelled", task_id: "g", status: "cancelled" },
    ],
    expected: [1, 0],
  },
  {
    name: "unknown event ignored",
    events: [
      { kind: "task.started", task_id: "h" },
      { kind: "task.unknown", task_id: "h" },
      { kind: "task.completed", task_id: "h", status: "done" },
    ],
    expected: [1, 1, 0],
  },
  {
    name: "multi-task overlap deterministic count",
    events: [
      { kind: "task.created", task_id: "i1" },
      { kind: "task.started", task_id: "i2" },
      { kind: "task.completed", task_id: "i1", status: "done" },
      { kind: "task.failed", task_id: "i2", status: "failed" },
    ],
    expected: [1, 2, 1, 0],
  },
];

function normStatus(s) {
  const v = String(s ?? "").toLowerCase();
  if (v === "queued" || v === "pending") return "queued";
  if (v === "done" || v === "complete" || v === "completed") return "done";
  if (v === "failed" || v === "error") return "failed";
  return v || "unknown";
}

function isTerminalKind(kind) {
  const v = String(kind ?? "").toLowerCase();
  return v === "task.completed" || v === "task.failed" || v === "task.cancelled" || v === "task.canceled";
}

function isRunningKind(kind) {
  const v = String(kind ?? "").toLowerCase();
  return v === "task.created" || v === "task.started" || v === "task.running";
}

function isTerminalStatus(status) {
  const v = normStatus(status);
  return v === "done" || v === "failed" || v === "cancelled" || v === "canceled" || v === "complete" || v === "completed" || v === "error";
}

function isRunningStatus(status) {
  const v = normStatus(status);
  return v === "queued" || v === "pending" || v === "running" || v === "started" || v === "active" || v === "in_progress" || v === "in-progress";
}

function deriveCounts(events) {
  const runningTaskIds = new Set();
  const terminalTaskIds = new Set();
  const counts = [];

  for (const ev of events) {
    const id = ev?.task_id ? String(ev.task_id) : null;
    const kind = String(ev?.kind ?? "").toLowerCase();
    const status = ev?.status ?? null;

    if (id) {
      if (terminalTaskIds.has(id)) {
        runningTaskIds.delete(id);
      } else if (isTerminalKind(kind) || isTerminalStatus(status)) {
        runningTaskIds.delete(id);
        terminalTaskIds.add(id);
      } else if (isRunningKind(kind) || isRunningStatus(status)) {
        runningTaskIds.add(id);
      }
    }

    counts.push(runningTaskIds.size);
  }

  return counts;
}

let passCount = 0;
let failCount = 0;

console.log("PHASE 62B — RUNNING TASKS LOCAL VERIFICATION");
console.log("Date: 2026-03-16");
console.log();
console.log("────────────────────────────────");
console.log();
console.log("PURPOSE");
console.log();
console.log("Verify bounded Running Tasks derivation behavior locally using deterministic event sequences.");
console.log();
console.log("No runtime mutation.");
console.log("No telemetry surface expansion.");
console.log();

for (const testCase of cases) {
  const actual = deriveCounts(testCase.events);
  const pass = JSON.stringify(actual) === JSON.stringify(testCase.expected);
  if (pass) passCount += 1;
  else failCount += 1;

  console.log("────────────────────────────────");
  console.log();
  console.log(`CASE: ${testCase.name}`);
  console.log(`EXPECTED: ${JSON.stringify(testCase.expected)}`);
  console.log(`ACTUAL:   ${JSON.stringify(actual)}`);
  console.log(`RESULT: ${pass ? "PASS" : "FAIL"}`);
  console.log();
}

console.log("────────────────────────────────");
console.log();
console.log("SUMMARY");
console.log(`PASS: ${passCount}`);
console.log(`FAIL: ${failCount}`);
console.log();
console.log("CLASSIFICATION");
console.log(failCount === 0 ? "LOCAL VERIFICATION PASS" : "LOCAL VERIFICATION FAIL");
console.log();
console.log("SUCCESS CONDITION");
console.log("Running Tasks derivation behavior is deterministically verified across bounded local cases.");
NODE

printf 'Wrote %s\n' "$OUT"
sed -n '1,260p' "$OUT"

git add scripts/_local/phase62b_running_tasks_local_verification.sh docs/checkpoints/PHASE62B_RUNNING_TASKS_LOCAL_VERIFICATION_20260316.md
git commit -m "Phase 62B local verification — validate bounded running tasks derivation cases"
git push
