PHASE 84.17 — DERIVED TELEMETRY CONTINUATION
Task Execution Duration Registry Entry

Date: 2026-03-17

OBJECTIVE

Formally register:

task_execution_duration_ms

as derived telemetry following safety approval.

Registry action only.

No implementation changes.

METRIC REGISTRY ENTRY

Metric name:

task_execution_duration_ms

Classification:

DERIVED TELEMETRY

Authority level:

READ_ONLY

Definition:

completed_at - started_at

Purpose:

Measure actual execution time separate from queue delay and lifecycle duration.

REGISTRY CONSTRAINTS

Metric must remain:

Observational only
Non-authoritative
Non-behavioral
Non-scheduling
Non-automation

Metric must NEVER:

Drive branching logic
Change execution path
Trigger automation
Modify scheduling
Trigger retries
Influence reducers
Influence policy

If referenced:

Context only.

GOVERNANCE RULE

Future reclassification requires:

Safety review
Authority review
Corridor compliance review
Verification review

Prevents:

Silent authority expansion.

BOUNDARY RULE

Metric may exist only within:

derived_telemetry/

Must NOT enter:

Reducers
Scheduler
Automation engine
Policy layer
Worker execution logic

Isolation required.

CORRIDOR COMPLIANCE

Administrative only.
No runtime changes.
No authority expansion.
No automation expansion.
No reducer mutation.

Phase 62B corridor preserved.

STATUS

Metric formally registered.

NEXT PHASE

Phase 84.18 — Execution Duration Verification Harness

END PHASE 84.17
