PHASE 84.6 — DERIVED TELEMETRY CONTINUATION
Task Total Lifecycle Duration Dashboard Read-Only Exposure Plan

Date: 2026-03-17

OBJECTIVE

Define safe UI exposure boundaries for task_total_lifecycle_duration_ms.

Informational only.
No behavioral integration.

EXPOSURE MODEL

Classification:

READ_ONLY TELEMETRY

Allowed display:

Running tasks panel
Completed tasks panel
Run detail view
Diagnostics panels
Lifecycle performance dashboards

Display format:

Milliseconds
Optional seconds conversion

Example:

12850 ms
12.85 s

Formatting must NOT:

Change value
Smooth value
Predict value
Create trends automatically

Raw display only.

UI SAFETY RULES

Metric must NEVER:

Trigger alerts automatically
Trigger retries
Trigger automation
Influence scheduling
Change task ordering
Influence priority

Metric may ONLY:

Provide lifecycle context.

OPERATOR INTERPRETATION RULE

Lifecycle duration represents:

End-to-end elapsed task time.

Does NOT represent:

Execution speed alone
Worker performance alone
Policy violations
Automation signals

Requires comparison with:

Execution duration
Queue wait duration
Retry count
Worker load

IMPLEMENTATION DISCIPLINE

UI integration allowed only in:

Dashboard presentation layer.

Must NOT enter:

Reducers
Scheduler
Automation engine
Policy layer
Execution lifecycle

Presentation boundary enforced.

CORRIDOR COMPLIANCE

Planning only.
No runtime mutation.
No authority expansion.
No automation expansion.
No reducer mutation.

Phase 62B corridor preserved.

STATUS

Exposure boundaries defined.
Safe for documentation update.

END PHASE 84.6
