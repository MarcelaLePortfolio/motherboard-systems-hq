PHASE 82.6 — DERIVED TELEMETRY CONTINUATION
Task Execution Duration Dashboard Read-Only Exposure Plan

Date: 2026-03-17

────────────────────────────────

OBJECTIVE

Define safe UI exposure boundaries for execution_duration_ms.

Purpose:

Operator visibility
Runtime diagnostics clarity
Performance interpretation support

Strictly informational.

No behavioral integration permitted.

────────────────────────────────

EXPOSURE MODEL

Metric exposure classification:

READ-ONLY TELEMETRY

Display allowed in:

Running Tasks panel
Completed Tasks panel
Run detail view
Diagnostics panels
Future performance dashboards

Display format:

Duration (ms)
Optional human readable format (seconds)

Example:

8421 ms
8.4 s

Formatting must NOT:

Change metric value
Apply smoothing
Apply prediction
Apply trend logic

Raw value display only.

────────────────────────────────

UI SAFETY RULES

Metric must NEVER:

Trigger color alerts automatically
Trigger retries
Trigger automation
Trigger task escalation
Influence scheduling priority
Change task ordering

Metric may:

Be visually grouped with other passive metrics.

Example:

status | duration | lease_epoch | attempts

Context only.

────────────────────────────────

OPERATOR INTERPRETATION RULE

Dashboard must treat duration as:

Diagnostic signal.

NOT:

Health signal
Failure signal
Automation signal

Operator guidance must clarify:

Long duration ≠ failure
Short duration ≠ success

Multi-metric interpretation required.

────────────────────────────────

IMPLEMENTATION DISCIPLINE

UI integration must occur only in:

Dashboard presentation layer

Must NOT enter:

Reducers
Scheduler
Automation engine
Policy evaluation
Task lifecycle engine

Presentation boundary enforced.

────────────────────────────────

FUTURE SAFETY GUARD

If future developer attempts:

if (execution_duration_ms > X)

System must require:

Safety review
Authority classification review
Corridor compliance validation

Metric cannot silently become decision input.

────────────────────────────────

CORRIDOR COMPLIANCE

This phase obeys:

Planning only
No runtime change
No authority change
No automation change
No reducer mutation

Phase 62B corridor preserved.

────────────────────────────────

NEXT PHASE

Phase 82.7 — Derived Telemetry Documentation Update

Goal:

Update telemetry documentation to include execution_duration_ms.

────────────────────────────────

STATUS

Exposure boundaries defined.
UI safety model established.
Ready for documentation update.

END PHASE 82.6
