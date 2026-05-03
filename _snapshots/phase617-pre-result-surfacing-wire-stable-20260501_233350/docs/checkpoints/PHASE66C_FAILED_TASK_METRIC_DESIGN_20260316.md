STATE NOTE — PHASE 66C FAILED TASK METRIC DESIGN
Failed Task Observability Metric
Date: 2026-03-16

────────────────────────────────

OBJECTIVE

Design deterministic failed task metric.

DATA ONLY.
NO UI CHANGE.

────────────────────────────────

DATA SOURCE

/events/task-events

Events used:

task.failed

Identifiers:

task_id
run_id
ts

────────────────────────────────

DETERMINISTIC MODEL

Maintain failure counter:

Increment on:

task.failed

Optional future model:

Rolling window:

Maintain timestamp list:

failed_events[]

Remove entries older than window.

Failed Tasks =
size(failed_events)

Initial implementation:

Simple monotonic counter.

────────────────────────────────

REDUCER OWNERSHIP

Reducer file:

public/js/telemetry_failed_tasks_reducer.js

Single ownership rule applies.

────────────────────────────────

REDUCER CONTRACT

Reducer must:

Be idempotent
Ignore malformed events
Never decrement counter
Never mutate layout
Register only with telemetry bus

Reducer must NOT:

Share state
Touch DOM
Depend on other reducers

────────────────────────────────

VERIFICATION TARGETS

Reducer valid if:

Failure count deterministic
Replay stable
Protection gate passes
No layout drift

────────────────────────────────

NEXT TARGET

Phase 66D:

Implement reducer.

────────────────────────────────

END PHASE 66C DESIGN
