STATE NOTE — PHASE 66C REDUCER EVENT ASSUMPTIONS DOCUMENTATION
Reducer Event Assumptions Corridor
Date: 2026-03-16

────────────────────────────────

OBJECTIVE

Formally document reducer event assumptions so future telemetry work
cannot accidentally violate reducer correctness or determinism.

This is a documentation-only phase.

NO layout changes.
NO reducer changes.
NO ownership changes.
NO UI mutation.
NO binding work.

────────────────────────────────

WHY THIS PHASE EXISTS

Phase 66A verified reducer correctness.
Phase 66B added telemetry audit tooling.

To safely close Phase 66, reducer assumptions must be made explicit
so future phases understand:

What reducers expect
What reducers tolerate
What reducers ignore
What reducers must never receive

This prevents silent telemetry drift.

────────────────────────────────

QUEUE DEPTH REDUCER ASSUMPTIONS

Event source:
task-events telemetry stream

Required fields:

task_id
state

Optional fields tolerated:

ts
run_id

Events treated as ADD:

task.created
task.queued

Events treated as REMOVE:

task.started
task.completed
task.failed
task.cancelled

Reducer protections:

Duplicate add events tolerated
Duplicate removal events tolerated
Removal without existing entry ignored
Malformed events ignored
Missing task_id ignored
Missing state ignored

Reducer guarantees:

Queue depth never negative
Queue depth deterministic across replay
Queue depth stable under duplicate events
Queue depth unaffected by unrelated events

────────────────────────────────

FAILED TASK REDUCER ASSUMPTIONS

Event source:

task-events telemetry stream

Required fields:

task_id
state

Optional fields tolerated:

run_id
ts

Events counted:

task.failed only

Events ignored:

task.created
task.queued
task.started
task.completed
task.cancelled

Reducer protections:

Duplicate failure events deduplicated
Malformed events ignored
Missing task_id ignored
Missing state ignored

Reducer guarantees:

Failed count monotonic
Failed count deterministic across replay
Failed count stable under duplicate events
Non-failure events never increment count

────────────────────────────────

GLOBAL TELEMETRY ASSUMPTIONS

Reducers assume:

Events may arrive out of order
Events may be duplicated
Events may be malformed
Events may be missing optional fields

Reducers must:

Fail safely
Ignore bad events
Never throw runtime errors
Never mutate UI
Never assume DOM presence
Never depend on metric tiles

Reducers must remain:

Data-layer only
Ownership neutral
Replay safe
Deterministic

────────────────────────────────

OWNERSHIP SAFETY ASSUMPTIONS

Reducers must NOT:

Reference metric tile IDs
Reference dashboard DOM
Write into compact tiles
Share ownership with metrics
Create implicit UI coupling

Reducers remain:

Unbound
Ownership neutral
Ready for future surfaces only

────────────────────────────────

PHASE 66 OUTCOME

Phase 66 observability expansion is now considered COMPLETE.

Completed work includes:

Reducer design
Runtime compatibility verification (Phase 67)
Reducer replay verification
Reducer determinism verification
Telemetry audit tooling
Reducer assumption documentation

Observability layer strengthened without UI risk.

────────────────────────────────

NEXT PHASE POSITION

Phase 66 CLOSED.

Next new feature phase becomes:

Phase 68.

Phase 67 remains closed as verification corridor.

System remains in protected engineering state.

────────────────────────────────

SYSTEM STATUS

Structurally stable
Protection corridor active
Ownership guards active
Reducers validated
Audit tooling active
Assumptions documented
No-bind decision preserved

System ready for next safe expansion phase.

────────────────────────────────

END PHASE 66C
