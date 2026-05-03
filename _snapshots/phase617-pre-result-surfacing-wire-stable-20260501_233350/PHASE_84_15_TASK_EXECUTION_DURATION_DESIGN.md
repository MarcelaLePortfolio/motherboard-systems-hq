PHASE 84.15 — DERIVED TELEMETRY CONTINUATION
Task Execution Duration Derived Metric Design

Date: 2026-03-17

OBJECTIVE

Define design for next derived telemetry metric:

task_execution_duration_ms

Design only.
No implementation.

METRIC DEFINITION

Name:

task_execution_duration_ms

Definition:

completed_at - started_at

Purpose:

Measure actual execution time separate from queue wait and lifecycle duration.

Provides operator clarity on:

Worker execution behavior
Runtime duration patterns
Execution vs lifecycle comparison

CLASSIFICATION

Telemetry class:

READ_ONLY DERIVED TELEMETRY

Authority:

NONE

Metric must NEVER:

Drive scheduling
Drive retries
Trigger automation
Change priority
Influence reducers
Influence policy

Metric is:

Observational only.

NULL SAFETY DESIGN

If started_at missing:

Result:

undefined

If completed_at missing:

Result:

undefined

If both missing:

Result:

undefined

INVALID ORDERING RULE

If:

completed_at < started_at

Result:

0

Negative durations must never exist.

Clamp required.

DETERMINISM RULE

Metric must use:

Stored timestamps only.

Must NOT use:

Date.now()
performance.now()
Runtime clocks
External state

Multiple runs must produce identical outputs.

IMPLEMENTATION BOUNDARY

Location:

derived_telemetry/

Must NOT enter:

Reducers
Scheduler
Automation engine
Policy layer
Worker execution paths

Strict telemetry isolation required.

RELATIONSHIP TO EXISTING METRICS

Forms time decomposition:

Queue Wait:

started_at - created_at

Execution Duration:

completed_at - started_at

Lifecycle Duration:

completed_at - created_at

Together provide:

Full operator time visibility.

CORRIDOR COMPLIANCE

Design only.
No runtime changes.
No authority expansion.
No automation expansion.
No reducer mutation.

Phase 62B corridor preserved.

STATUS

Design complete.

NEXT PHASE

Phase 84.16 — Execution Duration Safety Review

END PHASE 84.15
