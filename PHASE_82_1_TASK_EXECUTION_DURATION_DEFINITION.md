PHASE 82.1 — DERIVED TELEMETRY CONTINUATION
Task Execution Duration Metric Definition

Date: 2026-03-17

────────────────────────────────

OBJECTIVE

Define Task Execution Duration as a derived telemetry metric.

Purpose:

Provide visibility into runtime behavior of tasks.

This metric answers:

How long tasks take to execute after starting.

This complements:

Queue Wait Time → pre-execution pressure  
Execution Duration → runtime behavior  
Queue Latency → system responsiveness  

Execution observability triad now forming.

────────────────────────────────

METRIC DEFINITION

Execution Duration represents:

Time between run start and run completion.

Formula:

execution_duration_ms =

run_completed_ts − run_started_ts

If run not completed:

Metric undefined.

No estimation allowed.

No fallback allowed.

Strict observation only.

────────────────────────────────

CLASSIFICATION

Metric type:

Derived telemetry

Metric class:

EXECUTION_DERIVED_METRIC

Category:

Runtime diagnostics

Authority impact:

NONE

Automation impact:

NONE

Reducer impact:

NONE

Policy impact:

NONE

Classification:

PASSIVE OBSERVATION METRIC

────────────────────────────────

SAFETY CHARACTERISTICS

Metric does NOT:

Change execution behavior
Change retries
Change scheduling
Change priority
Change automation
Change task routing

Metric ONLY:

Measures elapsed runtime.

Pure observation.

────────────────────────────────

DATA SOURCE REQUIREMENTS

Metric must use only:

run_started_ts
run_completed_ts

No new fields allowed.

No event mutation allowed.

No inference allowed.

If timestamps missing:

Metric must not compute.

────────────────────────────────

INTERPRETATION DOMAIN

Execution Duration measures:

Runtime performance only.

It does NOT measure:

Queue pressure
Task priority
System latency
Failure risk

Single signal only.

Operator must use multi-signal interpretation.

────────────────────────────────

IMPLEMENTATION CONSTRAINTS

Metric must remain:

Pure function
Timestamp subtraction only
Deterministic
Side-effect free

Must NOT:

Touch reducers
Touch scheduler
Touch automation
Touch policy

Telemetry only.

────────────────────────────────

CORRIDOR COMPLIANCE

This phase obeys:

Definition only
No runtime mutation
No authority expansion
No automation expansion
No reducer mutation

Phase 62B corridor preserved.

────────────────────────────────

NEXT PHASE

Phase 82.2 — Pure Function Implementation

Goal:

Implement deterministic duration calculation.

────────────────────────────────

STATUS

Execution Duration metric defined.
Ready for pure function phase.

END PHASE 82.1
