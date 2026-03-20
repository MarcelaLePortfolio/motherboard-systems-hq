#!/usr/bin/env bash
set -euo pipefail

OUT="docs/checkpoints/PHASE62B_TASKS_COMPLETED_LOCAL_VERIFICATION_20260316.md"
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
    expected: [0, 0, 1],
  },
  {
    name: "started -> completed",
    events: [
      { kind: "task.started", task_id: "b" },
      { kind: "task.completed", task_id: "b", status: "done" },
    ],
    expected: [0, 1],
  },
  {
    name: "completed -> started",
    events: [
      { kind: "task.completed", task_id: "c", status: "done" },
      { kind: "task.started", task_id: "c" },
    ],
    expected: [1, 1],
  },
  {
    name: "duplicate completed",
    events: [
      { kind: "task.started", task_id: "d" },
      { kind: "task.completed", task_id: "d", status: "done" },
      { kind: "task.completed", task_id: "d", status: "done" },
    ],
    expected: [0, 1, 1],
  },
  {
    name: "created -> failed",
    events: [
      { kind: "task.created", task_id: "e" },
      { kind: "task.failed", task_id: "e", status: "failed" },
    ],
    expected: [0, 0],
  },
  {
    name: "created -> cancelled",
    events: [
      { kind: "task.created", task_id: "f" },
      { kind: "task.cancelled", task_id: "f", status: "cancelled" },
    ],
    expected: [0, 0],
  },
  {
    name: "failed -> completed",
    events: [
      { kind: "task.failed", task_id: "g", status: "failed" },
      { kind: "task.completed", task_id: "g", status: "done" },
    ],
    expected: [0, 1],
  },
  {
    name: "unknown event ignored",
    events: [
      { kind: "task.started", task_id: "h" },
      { kind: "task.unknown", task_id: "h" },
      { kind: "task.completed", task_id: "h", status: "done" },
    ],
    expected: [0, 0, 1],
  },
  {
    name: "multi-task overlap with mixed success/failure",
    events: [
      { kind: "task.created", task_id: "i1" },
      { kind: "task.started", task_id: "i2" },
      { kind: "task.completed", task_id: "i1", status: "done" },
      { kind: "task.failed", task_id: "i2", status: "failed" },
      { kind: "task.completed", task_id: "i3", status: "done" },
    ],
    expected: [0, 0, 1, 1, 2],
  },
];

function normStatus(s) {
  const v = String(s ?? "").toLowerCase();
  if (v === "queued" || v === "pending") return "queued";
  if (v === "done" || v === "complete" || v === "completed") return "done";
  if (v === "failed" || v === "error") return "failed";
  return v || "unknown";
}

function isSuccessKind(kind) {
  const v = String(kind ?? "").toLowerCase();
  return v === "task.completed";
}

function isFailureKind(kind) {
  const v = String(kind ?? "").toLowerCase();
  return v === "task.failed" || v === "task.cancelled" || v === "task.canceled";
}

function isSuccessStatus(status) {
  const v = normStatus(status);
  return v === "done" || v === "complete" || v === "completed";
}

function isFailureStatus(status) {
  const v = normStatus(status);
  return v === "failed" || v === "cancelled" || v === "canceled" || v === "error";
}

function deriveCounts(events) {
  const completedTaskIds = new Set();
  const counts = [];

  for (const ev of events) {
    const id = ev?.task_id ? String(ev.task_id) : null;
    const kind = String(ev?.kind ?? "").toLowerCase();
    const status = ev?.status ?? null;

    if (id && !completedTaskIds.has(id)) {
      if (isFailureKind(kind) || isFailureStatus(status)) {
        // no increment
      } else if (isSuccessKind(kind) || isSuccessStatus(status)) {
        completedTaskIds.add(id);
      }
    }

    counts.push(completedTaskIds.size);
  }

  return counts;
}

let passCount = 0;
let failCount = 0;

console.log("PHASE 62B — TASKS COMPLETED LOCAL VERIFICATION");
console.log("Date: 2026-03-16");
console.log();
console.log("────────────────────────────────");
console.log();
console.log("PURPOSE");
console.log();
console.log("Verify bounded Tasks Completed derivation behavior locally using deterministic event sequences.");
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
console.log("Tasks Completed derivation behavior is deterministically verified across bounded local cases.");
NODE

printf 'Wrote %s\n' "$OUT"
sed -n '1,260p' "$OUT"
