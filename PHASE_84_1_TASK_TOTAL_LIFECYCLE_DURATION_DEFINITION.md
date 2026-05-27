PHASE 84.1 — DERIVED TELEMETRY CONTINUATION
Task Total Lifecycle Duration Definition

Date: 2026-03-17

OBJECTIVE

Define task_total_lifecycle_duration_ms derived telemetry metric.

Definition only.
No runtime changes.

METRIC DEFINITION

Metric Name:

task_total_lifecycle_duration_ms

Metric Type:

Derived telemetry

Metric Class:

LIFECYCLE_DERIVED_METRIC

Definition:

Time between task creation and task completion.

Formula:

run_completed_ts − task_created_ts

Units:

Milliseconds

Domain:

Integer ≥ 0

Undefined when:

task_created_ts missing
run_completed_ts missing

Clamp rule:

Negative values clamp to 0.

SEMANTIC MEANING

Metric represents:

End-to-end task lifecycle duration.

Metric does NOT represent:

Execution efficiency
Worker health
Policy signals
Automation triggers
Retry logic
Task priority

Observation only.

AUTHORITY CLASSIFICATION

Authority impact:

NONE

Decision authority:

NONE

Automation authority:

NONE

Classification:

PASSIVE OBSERVATION METRIC

IMPLEMENTATION DISCIPLINE

Metric must remain:

Purely derived
Deterministic
Side-effect free

Must NOT:

Touch reducers
Touch scheduler
Touch automation
Touch policy layer
Modify execution flow

Telemetry only.

CORRIDOR COMPLIANCE

Definition only.
No runtime mutation.
No authority expansion.
No automation expansion.
No reducer mutation.

Phase 62B corridor preserved.

NEXT PHASE

Phase 84.2 — Pure Function Specification

STATUS

Lifecycle duration metric defined.
Ready for pure function phase.

END PHASE 84.1
