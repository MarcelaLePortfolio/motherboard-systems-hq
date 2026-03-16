PHASE 65C — QUEUE DEPTH METRIC CONTRACT
Date: 2026-03-15

OBJECTIVE

Hydrate Queue Depth as the next non-overlapping telemetry metric.

STRICT RULES

DATA / REDUCER CHANGE ONLY.
NO layout mutation.
NO ID changes.
NO wrapper additions.
NO script mount order changes.
NO dependency on Running Tasks reducer state.

SOURCE OF TRUTH

/events/task-events SSE stream

EXPECTED EVENT TYPES

task.created
task.queued
task.started
task.completed
task.failed
task.cancelled

PRIMARY KEY

task_id

METRIC DEFINITION

Queue Depth = tasks that exist but are not running yet.

DETERMINISTIC MODEL

Maintain pendingTasks set keyed by task_id.

ADD ON

task.created
task.queued

REMOVE ON

task.started
task.completed
task.failed
task.cancelled

FINAL VALUE

Queue Depth = size(pendingTasks)

SAFETY RULES

Use task_id as unique key.
Ignore duplicate events via Set semantics.
Remove on any terminal state.
Never count from history scans.
Never derive from Running Tasks state.

EDGE CASES

Restart:
pendingTasks rebuilds from new event flow.

Duplicate events:
Set prevents double add.

Out-of-order events:
remove remains safe and idempotent.

SUCCESS CRITERIA

Queue rises when tasks are created / queued.
Queue falls when tasks start.
Queue falls on completion / failure / cancel.
No layout drift.
No tab / workspace regression.
