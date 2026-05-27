STATE NOTE — PHASE 66A QUEUE DEPTH REDUCER DESIGN
Queue Depth Deterministic Reducer Specification
Date: 2026-03-16

────────────────────────────────

OBJECTIVE

Design deterministic reducer for Queue Depth metric.

NO UI CHANGES.
DATA LAYER ONLY.

────────────────────────────────

DATA SOURCE

/events/task-events SSE stream

Events used:

task.created
task.queued
task.started
task.completed
task.failed
task.cancelled

Primary identifiers:

task_id
run_id
ts
state

────────────────────────────────

DETERMINISTIC MODEL

Maintain queue_set:

ADD on:

task.created
task.queued

REMOVE on:

task.started
task.completed
task.failed
task.cancelled

Queue Depth:

queue_depth = size(queue_set)

────────────────────────────────

REDUCER OWNERSHIP

Reducer file:

public/js/telemetry_queue_depth_reducer.js

Single owner rule:

Queue Depth logic must exist ONLY in this reducer.

No cross-metric logic allowed.

────────────────────────────────

REDUCER CONTRACT

Reducer must:

Use Map or Set keyed by task_id
Be idempotent
Handle duplicate events safely
Handle out-of-order events safely
Ignore unknown states

Reducer must NOT:

Mutate DOM
Modify layout
Register listeners outside telemetry bus
Share state with other reducers

────────────────────────────────

FAILURE SAFETY RULES

If event missing task_id:

IGNORE EVENT

If removal event received without existing entry:

IGNORE EVENT

If duplicate add:

NO CHANGE

Reducer must remain deterministic.

────────────────────────────────

VERIFICATION TARGETS

Reducer passes if:

Queue count never negative
Queue count stable across replay
No layout mutation detected
Protection gate passes

────────────────────────────────

NEXT IMPLEMENTATION TARGET

Phase 66B:

Implement telemetry_queue_depth_reducer.js

No dashboard changes.

────────────────────────────────

END PHASE 66A DESIGN
